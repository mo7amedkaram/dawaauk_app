// lib/app/data/repositories/favorites_repository.dart
import 'package:get/get.dart';
import 'package:medication_database/app/data/local/database_manager.dart';
import '../models/medication_model.dart';

class FavoritesRepository extends GetxService {
  static FavoritesRepository get to => Get.find();

  final DatabaseManager _databaseManager = Get.find<DatabaseManager>();
  final RxList<Medication> favorites = <Medication>[].obs;

  // Initialisation
  Future<FavoritesRepository> init() async {
    await loadFavorites();
    return this;
  }

  // Charger tous les favoris
  Future<void> loadFavorites() async {
    try {
      final db = _databaseManager.database;
      if (db == null) return;

      // Obtenir les IDs des médicaments favoris
      final favResults =
          await db.query('favorites', orderBy: 'date_added DESC');
      if (favResults.isEmpty) {
        favorites.clear();
        return;
      }

      // Obtenir les détails des médicaments
      final medicationIds =
          favResults.map((row) => row['medication_id'] as int).toList();
      final placeholders = List.filled(medicationIds.length, '?').join(',');

      final medicationsResults = await db.query(
        'medications',
        where: 'id IN ($placeholders)',
        whereArgs: medicationIds,
      );

      final medicationsList = medicationsResults
          .map((row) => _databaseManager.medicationFromDatabaseRow(row))
          .toList();

      // Trier la liste selon l'ordre des favoris
      medicationsList.sort((a, b) {
        final aIndex = medicationIds.indexOf(a.id);
        final bIndex = medicationIds.indexOf(b.id);
        return aIndex.compareTo(bIndex);
      });

      favorites.value = medicationsList;
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Ajouter un médicament aux favoris
  Future<bool> addToFavorites(int medicationId) async {
    try {
      final db = _databaseManager.database;
      if (db == null) return false;

      // Vérifier si déjà en favoris
      final existingFav = await db.query(
        'favorites',
        where: 'medication_id = ?',
        whereArgs: [medicationId],
      );

      if (existingFav.isNotEmpty) return true; // Déjà en favoris

      // Ajouter aux favoris
      await db.insert(
        'favorites',
        {
          'medication_id': medicationId,
          'date_added': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Mettre à jour la liste des favoris
      await loadFavorites();
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Supprimer un médicament des favoris
  Future<bool> removeFromFavorites(int medicationId) async {
    try {
      final db = _databaseManager.database;
      if (db == null) return false;

      // Supprimer des favoris
      await db.delete(
        'favorites',
        where: 'medication_id = ?',
        whereArgs: [medicationId],
      );

      // Mettre à jour la liste des favoris
      await loadFavorites();
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Vérifier si un médicament est en favoris
  Future<bool> isFavorite(int medicationId) async {
    try {
      final db = _databaseManager.database;
      if (db == null) return false;

      final result = await db.query(
        'favorites',
        where: 'medication_id = ?',
        whereArgs: [medicationId],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }
}
