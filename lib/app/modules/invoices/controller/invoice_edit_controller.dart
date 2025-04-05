// lib/app/modules/invoice_edit/controllers/invoice_edit_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/local/database_manager.dart';

class InvoiceEditController extends GetxController {
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();
  final DatabaseManager _dbManager = Get.find<DatabaseManager>();

  // Contrôleurs de champs de texte
  final TextEditingController titleController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Données de la facture en cours d'édition
  final RxInt invoiceId = 0.obs;
  final RxBool isEditing = false.obs;

  // Médicaments et recherche
  final RxString searchQuery = ''.obs;
  final RxList<Medication> searchResults = <Medication>[].obs;
  final RxList<InvoiceItem> selectedItems = <InvoiceItem>[].obs;
  final RxDouble currentTotal = 0.0.obs;

  // États
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Observer les changements de recherche pour mettre à jour les résultats
    debounce(
      searchQuery,
      (_) => searchMedications(),
      time: const Duration(milliseconds: 500),
    );

    // Initialiser à partir des arguments
    if (Get.arguments != null) {
      if (Get.arguments['id'] != null) {
        invoiceId.value = Get.arguments['id'];
        isEditing.value = true;
      }

      if (Get.arguments['title'] != null) {
        titleController.text = Get.arguments['title'];
      }

      if (Get.arguments['customerName'] != null) {
        customerNameController.text = Get.arguments['customerName'];
      }

      if (Get.arguments['notes'] != null) {
        notesController.text = Get.arguments['notes'];
      }

      if (Get.arguments['isEditing'] != null) {
        isEditing.value = Get.arguments['isEditing'];
      }
    }

    // Si en mode édition, charger les données de la facture
    if (isEditing.value && invoiceId.value > 0) {
      loadInvoiceData();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    customerNameController.dispose();
    notesController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Mettre à jour la requête de recherche
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Rechercher des médicaments
  Future<void> searchMedications() async {
    if (searchQuery.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    try {
      final results = await _dbManager.searchMedications(
        query: searchQuery.value,
        limit: 10,
      );

      searchResults.value = results;
    } catch (e) {
      print('Error searching medications: $e');
    } finally {
      isSearching.value = false;
    }
  }

  // Charger les données d'une facture existante
  Future<void> loadInvoiceData() async {
    isLoading.value = true;

    try {
      final invoice = await _invoiceRepository.getInvoiceById(invoiceId.value);

      if (invoice != null) {
        // Remplir les contrôleurs de texte
        titleController.text = invoice.title;
        customerNameController.text = invoice.customerName;
        notesController.text = invoice.notes ?? '';

        // Remplir les articles
        selectedItems.value = invoice.items;

        // Mettre à jour le total
        updateTotal();
      } else {
        Get.snackbar(
          'خطأ',
          'تعذر تحميل بيانات الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error loading invoice data: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل بيانات الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un médicament à la facture
  void addMedication(Medication medication) {
    // Vérifier si le médicament est déjà dans la liste
    final existingIndex =
        selectedItems.indexWhere((item) => item.medicationId == medication.id);

    if (existingIndex >= 0) {
      // Incrémenter la quantité
      final existingItem = selectedItems[existingIndex];
      updateMedicationQuantity(
        medication.id,
        existingItem.quantity + 1,
      );
    } else {
      // Ajouter un nouvel article
      selectedItems.add(
        InvoiceItem.fromMedication(medication),
      );
    }

    // Effacer la recherche et mettre à jour le total
    searchController.clear();
    searchQuery.value = '';
    updateTotal();

    Get.snackbar(
      'تمت الإضافة',
      'تم إضافة ${medication.tradeName} إلى الفاتورة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Supprimer un médicament de la facture
  void removeMedication(int medicationId) {
    selectedItems.removeWhere((item) => item.medicationId == medicationId);
    updateTotal();
  }

  // Mettre à jour la quantité d'un médicament
  void updateMedicationQuantity(int medicationId, int quantity) {
    final index =
        selectedItems.indexWhere((item) => item.medicationId == medicationId);

    if (index >= 0) {
      final item = selectedItems[index];
      selectedItems[index] = item.copyWith(
        quantity: quantity,
        totalPrice: item.pricePerUnit * quantity,
      );
      updateTotal();
    }
  }

  // Mettre à jour le total de la facture
  void updateTotal() {
    currentTotal.value = Invoice.calculateTotal(selectedItems);
  }

  // Enregistrer la facture
  Future<void> saveInvoice() async {
    // Vérifier les champs obligatoires
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال عنوان الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (customerNameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال اسم العميل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إضافة دواء واحد على الأقل إلى الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isProcessing.value = true;

    try {
      // Créer l'objet facture
      final invoice = Invoice(
        id: isEditing.value ? invoiceId.value : null,
        title: titleController.text.trim(),
        customerName: customerNameController.text.trim(),
        dateCreated: DateTime.now(),
        totalAmount: currentTotal.value,
        status: Invoice.STATUS_PENDING,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        items: selectedItems,
      );

      bool result;
      if (isEditing.value) {
        // Mettre à jour une facture existante
        result = await _invoiceRepository.updateInvoice(invoice);
      } else {
        // Créer une nouvelle facture
        result = await _invoiceRepository.createInvoice(invoice);
      }

      if (result) {
        Get.back(); // Revenir à l'écran précédent

        Get.snackbar(
          'نجاح',
          isEditing.value
              ? 'تم تحديث الفاتورة بنجاح'
              : 'تم إنشاء الفاتورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          isEditing.value ? 'فشل في تحديث الفاتورة' : 'فشل في إنشاء الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error saving invoice: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
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
