// lib/app/modules/prescriptions/controllers/prescriptions_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/prescription_repository.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/models/medication_model.dart';

class PrescriptionsController extends GetxController
    with StateMixin<List<Prescription>> {
  final PrescriptionRepository _prescriptionRepository =
      Get.find<PrescriptionRepository>();
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();

  // Liste des ordonnances
  RxList<Prescription> get prescriptions =>
      _prescriptionRepository.prescriptions;

  // Filtre de statut actuel
  final RxString currentStatusFilter = 'all'.obs;

  // État de chargement
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;

  // Ordonnance en cours d'édition
  final Rx<Prescription?> currentPrescription = Rx<Prescription?>(null);

  // Médicaments sélectionnés pour une nouvelle ordonnance
  final RxList<PrescriptionItem> selectedItems = <PrescriptionItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPrescriptions();
  }

  // Charger toutes les ordonnances
  Future<void> loadPrescriptions() async {
    isLoading.value = true;
    change(null, status: RxStatus.loading());

    try {
      await _prescriptionRepository.loadPrescriptions();

      final filtered = _filterPrescriptions();

      if (filtered.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(filtered, status: RxStatus.success());
      }
    } catch (e) {
      change(null,
          status: RxStatus.error('حدث خطأ أثناء تحميل الوصفات الطبية'));
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les ordonnances selon le statut sélectionné
  List<Prescription> _filterPrescriptions() {
    if (currentStatusFilter.value == 'all') {
      return prescriptions;
    }

    return prescriptions
        .where((p) => p.status == currentStatusFilter.value)
        .toList();
  }

  // Changer le filtre de statut
  void changeStatusFilter(String status) {
    currentStatusFilter.value = status;
    final filtered = _filterPrescriptions();

    if (filtered.isEmpty) {
      change([], status: RxStatus.empty());
    } else {
      change(filtered, status: RxStatus.success());
    }
  }

  // Obtenir une ordonnance par ID
  Future<Prescription?> getPrescriptionById(int id) async {
    return await _prescriptionRepository.getPrescriptionById(id);
  }

  // Préparer une nouvelle ordonnance
  void prepareNewPrescription() {
    currentPrescription.value = null;
    selectedItems.clear();
  }

  // Ajouter un médicament à l'ordonnance en cours
  void addMedicationToSelection(Medication medication,
      {int quantity = 1,
      String? dosage,
      String? duration,
      String? instructions}) {
    // Vérifier si le médicament est déjà dans la liste
    final existingIndex =
        selectedItems.indexWhere((item) => item.medicationId == medication.id);

    if (existingIndex >= 0) {
      // Mettre à jour la quantité si le médicament existe déjà
      final existingItem = selectedItems[existingIndex];
      selectedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        dosage: dosage ?? existingItem.dosage,
        duration: duration ?? existingItem.duration,
        instructions: instructions ?? existingItem.instructions,
      );
    } else {
      // Ajouter un nouveau médicament
      selectedItems.add(PrescriptionItem(
        medicationId: medication.id,
        medication: medication,
        quantity: quantity,
        dosage: dosage,
        duration: duration,
        instructions: instructions,
      ));
    }
  }

  // Supprimer un médicament de l'ordonnance en cours
  void removeMedicationFromSelection(int medicationId) {
    selectedItems.removeWhere((item) => item.medicationId == medicationId);
  }

  // Mettre à jour un médicament dans l'ordonnance en cours
  void updateMedicationInSelection(int medicationId,
      {int? quantity, String? dosage, String? duration, String? instructions}) {
    final index =
        selectedItems.indexWhere((item) => item.medicationId == medicationId);
    if (index >= 0) {
      final item = selectedItems[index];
      selectedItems[index] = item.copyWith(
        quantity: quantity ?? item.quantity,
        dosage: dosage ?? item.dosage,
        duration: duration ?? item.duration,
        instructions: instructions ?? item.instructions,
      );
    }
  }

  // Créer une nouvelle ordonnance
  Future<bool> createPrescription(
      String title, String customerName, String? notes) async {
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إضافة دواء واحد على الأقل إلى الوصفة الطبية',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isProcessing.value = true;

    try {
      final newPrescription = Prescription(
        title: title,
        customerName: customerName,
        dateCreated: DateTime.now(),
        status: Prescription.STATUS_ACTIVE,
        notes: notes,
        items: selectedItems,
      );

      final result =
          await _prescriptionRepository.createPrescription(newPrescription);

      if (result) {
        Get.back(); // Retourner à la liste des ordonnances
        Get.snackbar(
          'نجاح',
          'تم إنشاء الوصفة الطبية بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadPrescriptions();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في إنشاء الوصفة الطبية',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Charger une ordonnance pour modification
  Future<void> loadPrescriptionForEdit(int id) async {
    isLoading.value = true;

    try {
      final prescription =
          await _prescriptionRepository.getPrescriptionById(id);
      if (prescription != null) {
        currentPrescription.value = prescription;
        selectedItems.value = List.from(prescription.items);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une ordonnance existante
  Future<bool> updatePrescription(int id, String title, String customerName,
      String status, String? notes) async {
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب إضافة دواء واحد على الأقل إلى الوصفة الطبية',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isProcessing.value = true;

    try {
      final originalPrescription =
          await _prescriptionRepository.getPrescriptionById(id);
      if (originalPrescription == null) {
        Get.snackbar(
          'خطأ',
          'الوصفة الطبية غير موجودة',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final updatedPrescription = originalPrescription.copyWith(
        title: title,
        customerName: customerName,
        status: status,
        notes: notes,
        items: selectedItems,
      );

      final result =
          await _prescriptionRepository.updatePrescription(updatedPrescription);

      if (result) {
        Get.back(); // Retourner à la liste des ordonnances
        Get.snackbar(
          'نجاح',
          'تم تحديث الوصفة الطبية بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadPrescriptions();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تحديث الوصفة الطبية',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Supprimer une ordonnance
  Future<bool> deletePrescription(int id) async {
    isProcessing.value = true;

    try {
      final result = await _prescriptionRepository.deletePrescription(id);

      if (result) {
        Get.snackbar(
          'نجاح',
          'تم حذف الوصفة الطبية بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadPrescriptions();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في حذف الوصفة الطبية',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Changer le statut d'une ordonnance
  Future<bool> changePrescriptionStatus(int id, String newStatus) async {
    isProcessing.value = true;

    try {
      final result =
          await _prescriptionRepository.changePrescriptionStatus(id, newStatus);

      if (result) {
        Get.snackbar(
          'نجاح',
          'تم تغيير حالة الوصفة الطبية بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Rafraîchir la liste
        await loadPrescriptions();
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تغيير حالة الوصفة الطبية',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      return result;
    } finally {
      isProcessing.value = false;
    }
  }

  // Convertir une ordonnance en facture
  Future<bool> convertToInvoice(int id) async {
    isProcessing.value = true;

    try {
      final result = await _prescriptionRepository.convertToInvoice(id);

      if (result['success']) {
        // Créer la facture avec les données converties
        final invoiceCreated = await _invoiceRepository
            .createInvoiceFromData(result['invoice_data']);

        if (invoiceCreated) {
          Get.snackbar(
            'نجاح',
            'تم تحويل الوصفة الطبية إلى فاتورة بنجاح',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          Get.snackbar(
            'خطأ',
            'فشل في إنشاء الفاتورة',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        Get.snackbar(
          'خطأ',
          result['message'] ?? 'فشل في تحويل الوصفة الطبية إلى فاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } finally {
      isProcessing.value = false;
    }
  }
}
