// lib/app/data/local/database_manager.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication_model.dart';
import '../providers/api_provider.dart';

class DatabaseManager extends GetxService {
  static DatabaseManager get to => Get.find();

  Database? get database => database;

  set database(Database? value) => database = value;
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final _box = GetStorage();

  // État de synchronisation et statistiques
  final RxBool isSyncing = false.obs;
  final RxDouble syncProgress = 0.0.obs;
  final RxString syncStatus = ''.obs;
  final RxInt lastSyncTimestamp = 0.obs;

  // Getters pour vérifier l'état
  bool get isFirstLaunch => _box.read('is_first_launch') ?? true;
  bool get hasDatabaseDownloaded => _box.read('database_downloaded') ?? false;
  DateTime? get lastSyncDate => _getLastSyncDate();

  // Initialisation du service
  Future<DatabaseManager> init() async {
    await _initDatabase();
    _loadLastSyncTimestamp();
    return this;
  }

  // Charger la date de dernière synchronisation
  void _loadLastSyncTimestamp() {
    lastSyncTimestamp.value = _box.read('last_sync_timestamp') ?? 0;
  }

  DateTime? _getLastSyncDate() {
    if (lastSyncTimestamp.value == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp.value);
  }

  // Initialisation de la base de données
  Future<void> _initDatabase() async {
    if (database != null) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'medicationsdatabase.db');

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Créer les tables
        await db.execute('''
          CREATE TABLE medications (
            id INTEGER PRIMARY KEY,
            trade_name TEXT,
            scientific_name TEXT,
            company TEXT,
            current_price REAL,
            old_price REAL,
            category TEXT,
            visit_count INTEGER,
            details TEXT,
            updated_at INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY,
            name TEXT,
            arabic_name TEXT,
            description TEXT,
            updated_at INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            medication_id INTEGER,
            date_added INTEGER,
            FOREIGN KEY (medication_id) REFERENCES medications (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE prescriptions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            customer_name TEXT,
            date_created INTEGER,
            status TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE prescription_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prescription_id INTEGER,
            medication_id INTEGER,
            dosage TEXT,
            duration TEXT,
            instructions TEXT,
            quantity INTEGER DEFAULT 1,
            FOREIGN KEY (prescription_id) REFERENCES prescriptions (id) ON DELETE CASCADE,
            FOREIGN KEY (medication_id) REFERENCES medications (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            customer_name TEXT,
            date_created INTEGER,
            total_amount REAL,
            status TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE invoice_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_id INTEGER,
            medication_id INTEGER,
            quantity INTEGER,
            price_per_unit REAL,
            total_price REAL,
            FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE,
            FOREIGN KEY (medication_id) REFERENCES medications (id)
          )
        ''');

        // Créer les index pour améliorer les performances
        await db.execute(
            "CREATE INDEX idx_medications_name ON medications (trade_name)");
        await db.execute(
            "CREATE INDEX idx_medications_scientific ON medications (scientific_name)");
        await db.execute(
            "CREATE INDEX idx_medications_category ON medications (category)");
      },
    );

    // Vérifier si c'est le premier lancement
    if (isFirstLaunch) {
      await _box.write('is_first_launch', false);
    }
  }

  // Télécharger la base de données complète
  Future<bool> downloadFullDatabase() async {
    try {
      isSyncing.value = true;
      syncStatus.value = 'جاري تحميل قاعدة البيانات...';
      syncProgress.value = 0.0;

      // 1. Télécharger toutes les catégories
      syncStatus.value = 'جاري تحميل التصنيفات...';
      final categoriesResponse = await _apiProvider.getCategories();
      if (categoriesResponse.status.hasError) {
        throw Exception("فشل تحميل التصنيفات");
      }

      final batch = database!.batch();
      final categories = categoriesResponse.body['categories'] as List;
      for (int i = 0; i < categories.length; i++) {
        final category = Category.fromJson(categories[i]);
        batch.insert(
          'categories',
          {
            'id': category.id,
            'name': category.name,
            'arabic_name': category.arabicName,
            'description': category.description,
            'updated_at': DateTime.now().millisecondsSinceEpoch
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        syncProgress.value = 0.3 * (i / categories.length);
      }
      await batch.commit(noResult: true);

      // 2. Télécharger tous les médicaments (en lots pour éviter les problèmes de mémoire)
      syncStatus.value = 'جاري تحميل بيانات الأدوية...';
      int page = 1;
      bool hasMoreData = true;
      int totalPages = 1;

      while (hasMoreData) {
        final medicationsResponse = await _apiProvider.searchMedications(
          query: '',
          page: page,
          limit: 50, // Télécharger par lots de 50
        );

        if (medicationsResponse.status.hasError) {
          throw Exception("فشل تحميل بيانات الأدوية");
        }

        final searchResponse =
            SearchResponse.fromJson(medicationsResponse.body);
        totalPages = searchResponse.pages;

        if (searchResponse.results.isEmpty) {
          hasMoreData = false;
          continue;
        }

        final medBatch = database!.batch();
        for (final medication in searchResponse.results) {
          medBatch.insert(
            'medications',
            {
              'id': medication.id,
              'trade_name': medication.tradeName,
              'scientific_name': medication.scientificName,
              'company': medication.company,
              'current_price': medication.currentPrice,
              'old_price': medication.oldPrice,
              'category': medication.category,
              'visit_count': medication.visitCount ?? 0,
              'details': medication.details != null
                  ? medicationDetailsToJson(medication.details!)
                  : null,
              'updated_at': DateTime.now().millisecondsSinceEpoch
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await medBatch.commit(noResult: true);

        // Mettre à jour la progression
        syncProgress.value = 0.3 + 0.7 * (page / totalPages);
        syncStatus.value = 'جاري تحميل بيانات الأدوية ($page/$totalPages)...';

        page++;
        if (page > totalPages) hasMoreData = false;
      }

      // Marquer la base de données comme téléchargée
      await _box.write('database_downloaded', true);
      await _updateLastSyncTimestamp();

      syncProgress.value = 1.0;
      syncStatus.value = 'تم تحميل قاعدة البيانات بنجاح';
      return true;
    } catch (e) {
      syncStatus.value = 'حدث خطأ أثناء التحميل: ${e.toString()}';
      print('Error downloading database: $e');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // Mettre à jour la base de données
  Future<bool> updateDatabase() async {
    try {
      isSyncing.value = true;
      syncStatus.value = 'جاري تحديث قاعدة البيانات...';
      syncProgress.value = 0.0;

      final lastUpdate = lastSyncDate ?? DateTime(2000);

      // 1. Mettre à jour les catégories modifiées
      syncStatus.value = 'جاري تحديث التصنيفات...';
      final categoriesResponse = await _apiProvider.getUpdatedCategories(
        since: lastUpdate.millisecondsSinceEpoch,
      );

      if (!categoriesResponse.status.hasError &&
          categoriesResponse.body['categories'] != null) {
        final updatedCategories =
            (categoriesResponse.body['categories'] as List)
                .map((e) => Category.fromJson(e))
                .toList();

        final batch = database!.batch();
        for (final category in updatedCategories) {
          batch.insert(
            'categories',
            {
              'id': category.id,
              'name': category.name,
              'arabic_name': category.arabicName,
              'description': category.description,
              'updated_at': DateTime.now().millisecondsSinceEpoch
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);

        syncProgress.value = 0.3;
      }

      // 2. Mettre à jour les médicaments modifiés
      syncStatus.value = 'جاري تحديث بيانات الأدوية...';
      final medicationsResponse = await _apiProvider.getUpdatedMedications(
        since: lastUpdate.millisecondsSinceEpoch,
      );

      if (!medicationsResponse.status.hasError &&
          medicationsResponse.body['medications'] != null) {
        final updatedMedications =
            (medicationsResponse.body['medications'] as List)
                .map((e) => Medication.fromJson(e))
                .toList();

        final batch = database!.batch();
        for (int i = 0; i < updatedMedications.length; i++) {
          final medication = updatedMedications[i];
          batch.insert(
            'medications',
            {
              'id': medication.id,
              'trade_name': medication.tradeName,
              'scientific_name': medication.scientificName,
              'company': medication.company,
              'current_price': medication.currentPrice,
              'old_price': medication.oldPrice,
              'category': medication.category,
              'visit_count': medication.visitCount ?? 0,
              'details': medication.details != null
                  ? medicationDetailsToJson(medication.details!)
                  : null,
              'updated_at': DateTime.now().millisecondsSinceEpoch
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          syncProgress.value = 0.3 + 0.7 * (i / updatedMedications.length);
        }
        await batch.commit(noResult: true);
      }

      await _updateLastSyncTimestamp();

      syncProgress.value = 1.0;
      syncStatus.value = 'تم تحديث قاعدة البيانات بنجاح';
      return true;
    } catch (e) {
      syncStatus.value = 'حدث خطأ أثناء التحديث: ${e.toString()}';
      print('Error updating database: $e');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // Mettre à jour le timestamp de dernière synchronisation
  Future<void> _updateLastSyncTimestamp() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _box.write('last_sync_timestamp', now);
    lastSyncTimestamp.value = now;
  }

  // Recherche de médicaments avec prise en charge des fautes de frappe
  Future<List<Medication>> searchMedications({
    String? query,
    String? category,
    String? company,
    String? scientificName,
    double? priceMin,
    double? priceMax,
    String sort = 'relevance',
    int page = 1,
    int limit = 20,
  }) async {
    if (database == null) return [];

    String where = '1=1';
    List<dynamic> whereArgs = [];

    // Créer la requête WHERE dynamiquement
    if (query != null && query.isNotEmpty) {
      // Utiliser la recherche floue avec LIKE et plusieurs conditions OR
      final searchTerms = query.split(' ').where((s) => s.isNotEmpty).toList();
      if (searchTerms.isNotEmpty) {
        String searchWhere = '(';
        for (var i = 0; i < searchTerms.length; i++) {
          final term = '%${searchTerms[i]}%';
          if (i > 0) searchWhere += ' OR ';
          searchWhere += 'trade_name LIKE ? OR scientific_name LIKE ?';
          whereArgs.add(term);
          whereArgs.add(term);
        }
        searchWhere += ')';
        where += ' AND $searchWhere';
      }
    }

    if (category != null && category.isNotEmpty) {
      where += ' AND category = ?';
      whereArgs.add(category);
    }

    if (company != null && company.isNotEmpty) {
      where += ' AND company = ?';
      whereArgs.add(company);
    }

    if (scientificName != null && scientificName.isNotEmpty) {
      where += ' AND scientific_name = ?';
      whereArgs.add(scientificName);
    }

    if (priceMin != null) {
      where += ' AND current_price >= ?';
      whereArgs.add(priceMin);
    }

    if (priceMax != null) {
      where += ' AND current_price <= ?';
      whereArgs.add(priceMax);
    }

    // Définir l'ordre de tri
    String orderBy;
    switch (sort) {
      case 'price_asc':
        orderBy = 'current_price ASC';
        break;
      case 'price_desc':
        orderBy = 'current_price DESC';
        break;
      case 'name_asc':
        orderBy = 'trade_name ASC';
        break;
      case 'name_desc':
        orderBy = 'trade_name DESC';
        break;
      case 'visits_desc':
        orderBy = 'visit_count DESC';
        break;
      default:
        // Par défaut, utiliser une formule de pertinence pour la recherche
        if (query != null && query.isNotEmpty) {
          // Ordonner par similarité
          orderBy = 'CASE WHEN trade_name LIKE ? THEN 1 '
              'WHEN trade_name LIKE ? THEN 2 '
              'WHEN scientific_name LIKE ? THEN 3 '
              'ELSE 4 END, '
              'trade_name ASC';
          whereArgs.add('$query%'); // Commence par le terme exact
          whereArgs.add('%$query%'); // Contient le terme
          whereArgs
              .add('%$query%'); // Contient le terme dans le nom scientifique
        } else {
          orderBy = 'visit_count DESC';
        }
    }

    // Calculer l'offset pour la pagination
    final offset = (page - 1) * limit;

    // Exécuter la requête
    final results = await database!.query(
      'medications',
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    // Convertir les résultats en objets Medication
    return results.map((row) => medicationFromDatabaseRow(row)).toList();
  }

  // Obtenir un médicament par ID
  Future<Medication?> getMedicationById(int id) async {
    if (database == null) return null;

    final results = await database!.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return medicationFromDatabaseRow(results.first);
  }

  // Obtenir toutes les catégories
  Future<List<Category>> getAllCategories() async {
    if (database == null) return [];

    final results = await database!.query(
      'categories',
      orderBy: 'arabic_name ASC',
    );

    return results.map((row) => categoryFromDatabaseRow(row)).toList();
  }

  // Incrémenter le compteur de visites pour un médicament
  Future<void> incrementVisitCount(int medicationId) async {
    if (database == null) return;

    await database!.rawUpdate(
        'UPDATE medications SET visit_count = visit_count + 1 WHERE id = ?',
        [medicationId]);
  }

  // Obtenir les médicaments similaires pour un nom
  Future<List<Medication>> getSimilarMedications(String name,
      {int limit = 5}) async {
    if (database == null) return [];

    // Implémenter une recherche basée sur la similarité
    final results = await database!.query(
      'medications',
      where: 'trade_name LIKE ? OR scientific_name LIKE ?',
      whereArgs: [
        '%${name.replaceAll(' ', '%')}%',
        '%${name.replaceAll(' ', '%')}%'
      ],
      orderBy: 'visit_count DESC',
      limit: limit,
    );

    return results.map((row) => medicationFromDatabaseRow(row)).toList();
  }

  // Convertir un MedicationDetails en JSON
  String medicationDetailsToJson(MedicationDetails details) {
    return '''
    {
      "indications": "${details.indications ?? ''}",
      "dosage": "${details.dosage ?? ''}",
      "side_effects": "${details.sideEffects ?? ''}",
      "contraindications": "${details.contraindications ?? ''}",
      "interactions": "${details.interactions ?? ''}",
      "storage_info": "${details.storageInfo ?? ''}",
      "usage_instructions": "${details.usageInstructions ?? ''}"
    }
    ''';
  }

  // Convertir une ligne de base de données en objet Medication
  Medication medicationFromDatabaseRow(Map<String, dynamic> row) {
    return Medication(
      id: row['id'],
      tradeName: row['trade_name'],
      scientificName: row['scientific_name'],
      company: row['company'],
      currentPrice: row['current_price'],
      oldPrice: row['old_price'],
      category: row['category'],
      visitCount: row['visit_count'],
      details: row['details'] != null
          ? MedicationDetails.fromJson(Map<String, dynamic>.from(
              (row['details'] as String).replaceAll('\n', '').trim() as Map))
          : null,
    );
  }

  // Convertir une ligne de base de données en objet Category
  Category categoryFromDatabaseRow(Map<String, dynamic> row) {
    return Category(
      id: row['id'],
      name: row['name'],
      arabicName: row['arabic_name'],
      description: row['description'],
    );
  }

  // Fermer la base de données
  Future<void> close() async {
    if (database != null) {
      await database!.close();
      database = null;
    }
  }
}
