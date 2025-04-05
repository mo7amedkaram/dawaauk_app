// lib/app/modules/invoices/controllers/invoices_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/medication_model.dart';

class InvoicesController extends GetxController with StateMixin<List<Invoice>> {
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();

  // Liste des factures
  RxList<Invoice> get invoices => _invoiceRepository.invoices;

  // Filtre de statut actuel
  final RxString currentStatusFilter = 'all'.obs;

  // Période de rapport
  final Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Statistiques
  final RxDouble totalSales = 0.0.obs;
  final Rx<Map<String, dynamic>> salesStats = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> topSellingMedications =
      <Map<String, dynamic>>[].obs;

  // État de chargement
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;

  // Facture en cours d'édition
  final Rx<Invoice?> currentInvoice = Rx<Invoice?>(null);

  // Médicaments sélectionnés pour une nouvelle facture
  final RxList<InvoiceItem> selectedItems = <InvoiceItem>[].obs;

  // Total de la facture en cours
  final RxDouble currentTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvoices();

    // Observer les changements dans les articles sélectionnés pour mettre à jour le total
    ever(selectedItems, (_) {
      updateCurrentTotal();
    });
  }

  // Mettre à jour le total actuel
  void updateCurrentTotal() {
    currentTotal.value = Invoice.calculateTotal(selectedItems);
  }

  // Charger toutes les factures
  Future<void> loadInvoices() async {
    isLoading.value = true;
    change(null, status: RxStatus.loading());

    try {
      await _invoiceRepository.loadInvoices();

      final filtered = _filterInvoices();

      if (filtered.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(filtered, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error('حدث خطأ أثناء تحميل الفواتير'));
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les factures selon le statut sélectionné
  List<Invoice> _filterInvoices() {
    if (currentStatusFilter.value == 'all') {
      return invoices;
    }

    return invoices
        .where((p) => p.status == currentStatusFilter.value)
        .toList();
  }

  // Changer le filtre de statut
  void changeStatusFilter(String status) {
    currentStatusFilter.value = status;
    final filtered = _filterInvoices();

    if (filtered.isEmpty) {
      change([], status: RxStatus.empty());
    } else {
      change(filtered, status: RxStatus.success());
    }
  }

  // Obtenir une facture par ID
  Future<Invoice?> getInvoiceById(int id) async {
    return await _invoiceRepository.getInvoiceById(id);
  }

  // Charger les statistiques de vente
  Future<void> loadSalesStatistics() async {
    isLoading.value = true;

    try {
      // Obtenir le total des ventes pour la période sélectionnée
      totalSales.value = await _invoiceRepository.getTotalSales(
        startDate: startDate.value,
        endDate: endDate.value,
      );

      // Obtenir les statistiques de vente par mois
      salesStats.value =
          await _invoiceRepository.getSalesStats(period: 'month');

      // Obtenir les médicaments les plus vendus
      topSellingMedications.value =
          await _invoiceRepository.getTopSellingMedications(limit: 10);
    } catch (e) {
      print('Error loading sales statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour la période de rapport
  void updateReportPeriod(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    loadSalesStatistics();
  }

  // Préparer une nouvelle facture
  void prepareNewInvoice() {
    currentInvoice.value = null;
    selectedItems.clear();
    currentTotal.value = 0.0;
  }

  // Ajouter un médicament à la facture en cours
  void addMedicationToInvoice(Medication medication, {int quantity = 1}) {
    // Vérifier si le médicament est déjà dans la liste
    final existingIndex =
        selectedItems.indexWhere((item) => item.medicationId == medication.id);

    if (existingIndex >= 0) {
      // Mettre à jour la quantité si le médicament existe déjà
      final existingItem = selectedItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      selectedItems[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
        totalPrice: medication.currentPrice * newQuantity,
      );
    } else {
      // Ajouter un nouveau médicament
      selectedItems.add(InvoiceItem.fromMedication(
        medication,
        quantity: quantity,
      ));
    }

    // Mettre à jour le total
    updateCurrentTotal();
  }

  // Supprimer un médicament de la facture en cours
  void removeMedicationFromInvoice(int medicationId) {
    selectedItems.removeWhere((item) => item.medicationId == medicationId);
    // Le total est mis à jour automatiquement grâce à l'observateur
  }

  // Mettre à jour la quantité d'un médicament dans la facture
  void updateMedicationQuantity(int medicationId, int quantity) {
    if (quantity <= 0) {
      removeMedicationFromInvoice(medicationId);
      return;
    }

    final index =
        selectedItems.indexWhere((item) => item.medicationId == medicationId);
    if (index >= 0) {
      final item = selectedItems[index];

      selectedItems[index] = item.copyWith(
        quantity: quantity,
        totalPrice: item.pricePerUnit * quantity,
      );
    }

    // Le total est mis à jour automatiquement grâce à l'observateur
  }

  // Créer une nouvelle facture
  Future<bool> createInvoice(
      String title, String customerName, String? notes) async {
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إضافة دواء واحد على الأقل إلى الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isProcessing.value = true;

    try {
      final newInvoice = Invoice(
        title: title,
        customerName: customerName,
        dateCreated: DateTime.now(),
        totalAmount: currentTotal.value,
        status: Invoice.STATUS_PENDING,
        notes: notes,
        items: selectedItems,
      );

      final result = await _invoiceRepository.createInvoice(newInvoice);

      if (result) {
        Get.back(); // Retourner à la liste des factures
        Get.snackbar(
          'نجاح',
          'تم إنشاء الفاتورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadInvoices();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في إنشاء الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Charger une facture pour modification
  Future<void> loadInvoiceForEdit(int id) async {
    isLoading.value = true;

    try {
      final invoice = await _invoiceRepository.getInvoiceById(id);
      if (invoice != null) {
        currentInvoice.value = invoice;
        selectedItems.value = List.from(invoice.items);
        updateCurrentTotal();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une facture existante
  Future<bool> updateInvoice(int id, String title, String customerName,
      String status, String? notes) async {
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إضافة دواء واحد على الأقل إلى الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isProcessing.value = true;

    try {
      final originalInvoice = await _invoiceRepository.getInvoiceById(id);
      if (originalInvoice == null) {
        Get.snackbar(
          'خطأ',
          'الفاتورة غير موجودة',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final updatedInvoice = originalInvoice.copyWith(
        title: title,
        customerName: customerName,
        totalAmount: currentTotal.value,
        status: status,
        notes: notes,
        items: selectedItems,
      );

      final result = await _invoiceRepository.updateInvoice(updatedInvoice);

      if (result) {
        Get.back(); // Retourner à la liste des factures
        Get.snackbar(
          'نجاح',
          'تم تحديث الفاتورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadInvoices();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تحديث الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Supprimer une facture
  Future<bool> deleteInvoice(int id) async {
    isProcessing.value = true;

    try {
      final result = await _invoiceRepository.deleteInvoice(id);

      if (result) {
        Get.snackbar(
          'نجاح',
          'تم حذف الفاتورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadInvoices();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Changer le statut d'une facture
  Future<bool> changeInvoiceStatus(int id, String newStatus) async {
    isProcessing.value = true;

    try {
      final result =
          await _invoiceRepository.changeInvoiceStatus(id, newStatus);

      if (result) {
        Get.snackbar(
          'نجاح',
          'تم تغيير حالة الفاتورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadInvoices();

        // Si le statut est passé à "payé", recharger également les statistiques
        if (newStatus == Invoice.STATUS_PAID) {
          await loadSalesStatistics();
        }
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تغيير حالة الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Exporter la facture en PDF
  Future<bool> exportInvoiceToPdf(int id) async {
    // Cette fonction sera implémentée plus tard avec une bibliothèque PDF
    Get.snackbar(
      'عذرا',
      'سيتم تنفيذ هذه الميزة قريبا',
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  // Formater les montants en devise locale
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
