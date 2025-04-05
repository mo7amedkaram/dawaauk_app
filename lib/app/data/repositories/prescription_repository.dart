// lib/app/data/repositories/prescription_repository.dart
import 'package:get/get.dart';
import '../models/prescription_model.dart';
import '../local/database_manager.dart';

class PrescriptionRepository extends GetxService {
  static PrescriptionRepository get to => Get.find();

  final DatabaseManager _dbManager = Get.find<DatabaseManager>();
  final RxList<Prescription> prescriptions = <Prescription>[].obs;

  // Initialisation
  Future<PrescriptionRepository> init() async {
    await loadPrescriptions();
    return this;
  }

  // Charger toutes les ordonnances
  Future<void> loadPrescriptions() async {
    try {
      final db = _dbManager.database;
      if (db == null) return;

      // Obtenir toutes les ordonnances
      final prescriptionsResult =
          await db.query('prescriptions', orderBy: 'date_created DESC');

      final List<Prescription> prescriptionsList = [];

      // Pour chaque ordonnance, obtenir ses items
      for (final prescRow in prescriptionsResult) {
        final prescriptionId = prescRow['id'] as int;

        // Obtenir les items de cette ordonnance
        final itemsResult = await db.query(
          'prescription_items',
          where: 'prescription_id = ?',
          whereArgs: [prescriptionId],
        );

        // Obtenir les détails des médicaments pour chaque item
        final List<PrescriptionItem> items = [];
        for (final itemRow in itemsResult) {
          final medicationId = itemRow['medication_id'] as int;
          final medication = await _dbManager.getMedicationById(medicationId);

          items.add(PrescriptionItem.fromJson(
            itemRow,
            medicationData: medication,
          ));
        }

        // Créer l'objet Prescription complet
        prescriptionsList.add(Prescription.fromJson(
          prescRow,
          prescriptionItems: items,
        ));
      }

      prescriptions.value = prescriptionsList;
    } catch (e) {
      print('Error loading prescriptions: $e');
    }
  }

  // Obtenir une ordonnance spécifique par ID
  Future<Prescription?> getPrescriptionById(int id) async {
    try {
      final db = _dbManager.database;
      if (db == null) return null;

      final prescResult = await db.query(
        'prescriptions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (prescResult.isEmpty) return null;

      // Obtenir les items de cette ordonnance
      final itemsResult = await db.query(
        'prescription_items',
        where: 'prescription_id = ?',
        whereArgs: [id],
      );

      // Obtenir les détails des médicaments pour chaque item
      final List<PrescriptionItem> items = [];
      for (final itemRow in itemsResult) {
        final medicationId = itemRow['medication_id'] as int;
        final medication = await _dbManager.getMedicationById(medicationId);

        items.add(PrescriptionItem.fromJson(
          itemRow,
          medicationData: medication,
        ));
      }

      return Prescription.fromJson(
        prescResult.first,
        prescriptionItems: items,
      );
    } catch (e) {
      print('Error getting prescription by id: $e');
      return null;
    }
  }

  // Créer une nouvelle ordonnance
  Future<bool> createPrescription(Prescription prescription) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Insérer l'ordonnance
        final prescriptionId = await txn.insert(
          'prescriptions',
          prescription.toJson(),
        );

        // Insérer les items
        for (final item in prescription.items) {
          await txn.insert(
            'prescription_items',
            {
              ...item.toJson(),
              'prescription_id': prescriptionId,
            },
          );
        }

        // Recharger les ordonnances
        await loadPrescriptions();
        return true;
      });
    } catch (e) {
      print('Error creating prescription: $e');
      return false;
    }
  }

  // Mettre à jour une ordonnance existante
  Future<bool> updatePrescription(Prescription prescription) async {
    try {
      final db = _dbManager.database;
      if (db == null || prescription.id == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Mettre à jour l'ordonnance
        await txn.update(
          'prescriptions',
          prescription.toJson(),
          where: 'id = ?',
          whereArgs: [prescription.id],
        );

        // Supprimer les anciens items
        await txn.delete(
          'prescription_items',
          where: 'prescription_id = ?',
          whereArgs: [prescription.id],
        );

        // Insérer les nouveaux items
        for (final item in prescription.items) {
          await txn.insert(
            'prescription_items',
            {
              ...item.toJson(),
              'prescription_id': prescription.id,
            },
          );
        }

        // Recharger les ordonnances
        await loadPrescriptions();
        return true;
      });
    } catch (e) {
      print('Error updating prescription: $e');
      return false;
    }
  }

  // Supprimer une ordonnance
  Future<bool> deletePrescription(int id) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Supprimer les items (la cascade supprime automatiquement)
        await txn.delete(
          'prescriptions',
          where: 'id = ?',
          whereArgs: [id],
        );

        // Recharger les ordonnances
        await loadPrescriptions();
        return true;
      });
    } catch (e) {
      print('Error deleting prescription: $e');
      return false;
    }
  }

  // Changer le statut d'une ordonnance
  Future<bool> changePrescriptionStatus(int id, String newStatus) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      await db.update(
        'prescriptions',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Recharger les ordonnances
      await loadPrescriptions();
      return true;
    } catch (e) {
      print('Error changing prescription status: $e');
      return false;
    }
  }

  // Convertir une ordonnance en facture
  Future<Map<String, dynamic>> convertToInvoice(int prescriptionId) async {
    try {
      final prescription = await getPrescriptionById(prescriptionId);
      if (prescription == null) {
        return {'success': false, 'message': 'Ordonnance non trouvée'};
      }

      // Créer les éléments de facture à partir des éléments d'ordonnance
      final invoiceItems = prescription.items
          .map((item) {
            final medication = item.medication;
            if (medication == null) {
              return null;
            }

            return {
              'medication_id': medication.id,
              'quantity': item.quantity,
              'price_per_unit': medication.currentPrice,
              'total_price': medication.currentPrice * item.quantity,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      if (invoiceItems.isEmpty) {
        return {
          'success': false,
          'message': 'Aucun médicament valide dans l\'ordonnance'
        };
      }

      // Calculer le total
      final totalAmount = invoiceItems.fold<double>(
          0.0, (sum, item) => sum + (item['total_price'] as double));

      // Créer la facture
      final invoiceData = {
        'title': 'فاتورة: ${prescription.title}',
        'customer_name': prescription.customerName,
        'date_created': DateTime.now().millisecondsSinceEpoch,
        'total_amount': totalAmount,
        'status': 'pending',
        'notes': 'تم إنشاؤها من الوصفة الطبية: ${prescription.title}',
        'items': invoiceItems,
      };

      return {
        'success': true,
        'invoice_data': invoiceData,
      };
    } catch (e) {
      print('Error converting prescription to invoice: $e');
      return {'success': false, 'message': 'Erreur lors de la conversion: $e'};
    }
  }
}
