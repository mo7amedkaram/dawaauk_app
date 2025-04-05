// lib/app/data/repositories/invoice_repository.dart
import 'package:get/get.dart';
import '../models/invoice_model.dart';
import '../local/database_manager.dart';

class InvoiceRepository extends GetxService {
  static InvoiceRepository get to => Get.find();

  final DatabaseManager _dbManager = Get.find<DatabaseManager>();
  final RxList<Invoice> invoices = <Invoice>[].obs;

  // Initialisation
  Future<InvoiceRepository> init() async {
    await loadInvoices();
    return this;
  }

  // Charger toutes les factures
  Future<void> loadInvoices() async {
    try {
      final db = _dbManager.database;
      if (db == null) return;

      // Obtenir toutes les factures
      final invoicesResult =
          await db.query('invoices', orderBy: 'date_created DESC');

      final List<Invoice> invoicesList = [];

      // Pour chaque facture, obtenir ses items
      for (final invRow in invoicesResult) {
        final invoiceId = invRow['id'] as int;

        // Obtenir les items de cette facture
        final itemsResult = await db.query(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [invoiceId],
        );

        // Obtenir les détails des médicaments pour chaque item
        final List<InvoiceItem> items = [];
        for (final itemRow in itemsResult) {
          final medicationId = itemRow['medication_id'] as int;
          final medication = await _dbManager.getMedicationById(medicationId);

          items.add(InvoiceItem.fromJson(
            itemRow,
            medicationData: medication,
          ));
        }

        // Créer l'objet Invoice complet
        invoicesList.add(Invoice.fromJson(
          invRow,
          invoiceItems: items,
        ));
      }

      invoices.value = invoicesList;
    } catch (e) {
      print('Error loading invoices: $e');
    }
  }

  // Obtenir une facture spécifique par ID
  Future<Invoice?> getInvoiceById(int id) async {
    try {
      final db = _dbManager.database;
      if (db == null) return null;

      final invResult = await db.query(
        'invoices',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (invResult.isEmpty) return null;

      // Obtenir les items de cette facture
      final itemsResult = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [id],
      );

      // Obtenir les détails des médicaments pour chaque item
      final List<InvoiceItem> items = [];
      for (final itemRow in itemsResult) {
        final medicationId = itemRow['medication_id'] as int;
        final medication = await _dbManager.getMedicationById(medicationId);

        items.add(InvoiceItem.fromJson(
          itemRow,
          medicationData: medication,
        ));
      }

      return Invoice.fromJson(
        invResult.first,
        invoiceItems: items,
      );
    } catch (e) {
      print('Error getting invoice by id: $e');
      return null;
    }
  }

  // Créer une nouvelle facture
  Future<bool> createInvoice(Invoice invoice) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Insérer la facture
        final invoiceId = await txn.insert(
          'invoices',
          invoice.toJson(),
        );

        // Insérer les items
        for (final item in invoice.items) {
          await txn.insert(
            'invoice_items',
            {
              ...item.toJson(),
              'invoice_id': invoiceId,
            },
          );
        }

        // Recharger les factures
        await loadInvoices();
        return true;
      });
    } catch (e) {
      print('Error creating invoice: $e');
      return false;
    }
  }

  // Créer une facture à partir des données
  Future<bool> createInvoiceFromData(Map<String, dynamic> invoiceData) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Préparer les données de la facture sans les items
        final Map<String, dynamic> invoiceMap = {
          'title': invoiceData['title'],
          'customer_name': invoiceData['customer_name'],
          'date_created': invoiceData['date_created'],
          'total_amount': invoiceData['total_amount'],
          'status': invoiceData['status'],
          'notes': invoiceData['notes'],
        };

        // Insérer la facture
        final invoiceId = await txn.insert('invoices', invoiceMap);

        // Insérer les items
        final items = invoiceData['items'] as List;
        for (final item in items) {
          await txn.insert(
            'invoice_items',
            {
              ...item,
              'invoice_id': invoiceId,
            },
          );
        }

        // Recharger les factures
        await loadInvoices();
        return true;
      });
    } catch (e) {
      print('Error creating invoice from data: $e');
      return false;
    }
  }

  // Mettre à jour une facture existante
  Future<bool> updateInvoice(Invoice invoice) async {
    try {
      final db = _dbManager.database;
      if (db == null || invoice.id == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Mettre à jour la facture
        await txn.update(
          'invoices',
          invoice.toJson(),
          where: 'id = ?',
          whereArgs: [invoice.id],
        );

        // Supprimer les anciens items
        await txn.delete(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [invoice.id],
        );

        // Insérer les nouveaux items
        for (final item in invoice.items) {
          await txn.insert(
            'invoice_items',
            {
              ...item.toJson(),
              'invoice_id': invoice.id,
            },
          );
        }

        // Recharger les factures
        await loadInvoices();
        return true;
      });
    } catch (e) {
      print('Error updating invoice: $e');
      return false;
    }
  }

  // Supprimer une facture
  Future<bool> deleteInvoice(int id) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      // Commencer une transaction
      return await db.transaction((txn) async {
        // Supprimer la facture (la cascade supprime automatiquement les items)
        await txn.delete(
          'invoices',
          where: 'id = ?',
          whereArgs: [id],
        );

        // Recharger les factures
        await loadInvoices();
        return true;
      });
    } catch (e) {
      print('Error deleting invoice: $e');
      return false;
    }
  }

  // Changer le statut d'une facture
  Future<bool> changeInvoiceStatus(int id, String newStatus) async {
    try {
      final db = _dbManager.database;
      if (db == null) return false;

      await db.update(
        'invoices',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Recharger les factures
      await loadInvoices();
      return true;
    } catch (e) {
      print('Error changing invoice status: $e');
      return false;
    }
  }

  // Obtenir le total des ventes
  Future<double> getTotalSales({DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = _dbManager.database;
      if (db == null) return 0.0;

      String whereClause = "status = 'paid'";
      List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereClause += " AND date_created >= ?";
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }

      if (endDate != null) {
        whereClause += " AND date_created <= ?";
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }

      final result = await db.rawQuery(
        '''
        SELECT SUM(total_amount) as total 
        FROM invoices 
        WHERE $whereClause
        ''',
        whereArgs,
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return double.parse(result.first['total'].toString());
      }

      return 0.0;
    } catch (e) {
      print('Error getting total sales: $e');
      return 0.0;
    }
  }

  // Obtenir les statistiques des ventes par période
  Future<Map<String, dynamic>> getSalesStats({String period = 'month'}) async {
    try {
      final db = _dbManager.database;
      if (db == null) return {};

      String groupBy;
      String dateFormat;

      // Configurer la période
      switch (period) {
        case 'day':
          groupBy =
              "strftime('%Y-%m-%d', datetime(date_created/1000, 'unixepoch', 'localtime'))";
          dateFormat = '%Y-%m-%d';
          break;
        case 'week':
          groupBy =
              "strftime('%Y-%W', datetime(date_created/1000, 'unixepoch', 'localtime'))";
          dateFormat = '%Y-Week %W';
          break;
        case 'month':
          groupBy =
              "strftime('%Y-%m', datetime(date_created/1000, 'unixepoch', 'localtime'))";
          dateFormat = '%Y-%m';
          break;
        case 'year':
          groupBy =
              "strftime('%Y', datetime(date_created/1000, 'unixepoch', 'localtime'))";
          dateFormat = '%Y';
          break;
        default:
          groupBy =
              "strftime('%Y-%m', datetime(date_created/1000, 'unixepoch', 'localtime'))";
          dateFormat = '%Y-%m';
      }

      final result = await db.rawQuery('''
        SELECT 
          $groupBy as period,
          COUNT(*) as count,
          SUM(total_amount) as total,
          AVG(total_amount) as average
        FROM invoices
        WHERE status = 'paid'
        GROUP BY period
        ORDER BY period DESC
        LIMIT 12
        ''');

      return {
        'labels': result.map((row) => row['period'] as String).toList(),
        'total': result
            .map((row) => (row['total'] as num?)?.toDouble() ?? 0.0)
            .toList(),
        'count':
            result.map((row) => (row['count'] as num?)?.toInt() ?? 0).toList(),
        'average': result
            .map((row) => (row['average'] as num?)?.toDouble() ?? 0.0)
            .toList(),
      };
    } catch (e) {
      print('Error getting sales stats: $e');
      return {};
    }
  }

  // Obtenir les médicaments les plus vendus
  Future<List<Map<String, dynamic>>> getTopSellingMedications(
      {int limit = 10}) async {
    try {
      final db = _dbManager.database;
      if (db == null) return [];

      final result = await db.rawQuery('''
        SELECT 
          m.id,
          m.trade_name,
          m.scientific_name,
          m.company,
          m.current_price,
          SUM(i.quantity) as total_quantity,
          SUM(i.total_price) as total_sales
        FROM invoice_items i
        JOIN medications m ON i.medication_id = m.id
        JOIN invoices inv ON i.invoice_id = inv.id
        WHERE inv.status = 'paid'
        GROUP BY i.medication_id
        ORDER BY total_quantity DESC
        LIMIT ?
        ''', [limit]);

      return result.map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (e) {
      print('Error getting top selling medications: $e');
      return [];
    }
  }
}
