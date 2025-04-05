// lib/app/modules/prescription_details/controllers/prescription_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/prescription_model.dart';
import '../../../data/repositories/prescription_repository.dart';
import '../../../data/repositories/invoice_repository.dart';

class PrescriptionDetailsController extends GetxController {
  final PrescriptionRepository _prescriptionRepository =
      Get.find<PrescriptionRepository>();
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();

  final RxInt prescriptionId = 0.obs;
  final Rx<Prescription?> prescription = Rx<Prescription?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Récupérer l'ID de l'ordonnance à partir des paramètres de route
    if (Get.parameters['id'] != null) {
      try {
        prescriptionId.value = int.parse(Get.parameters['id']!);
        loadPrescription();
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'معرف الوصفة غير صالح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else if (Get.arguments != null && Get.arguments['prescription'] != null) {
      // Si l'ordonnance a été passée directement via arguments
      prescription.value = Get.arguments['prescription'] as Prescription;
      prescriptionId.value = prescription.value!.id!;
    } else {
      Get.snackbar(
        'خطأ',
        'معرف الوصفة مطلوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Charger les détails de l'ordonnance
  Future<void> loadPrescription() async {
    isLoading.value = true;

    try {
      final result = await _prescriptionRepository
          .getPrescriptionById(prescriptionId.value);

      if (result != null) {
        prescription.value = result;
      } else {
        Get.snackbar(
          'خطأ',
          'تعذر تحميل تفاصيل الوصفة الطبية',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل تفاصيل الوصفة الطبية',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Modifier l'ordonnance
  void editPrescription() {
    if (prescription.value == null) return;

    if (prescription.value!.status != Prescription.STATUS_ACTIVE) {
      Get.snackbar(
        'غير مسموح',
        'يمكن تعديل الوصفات التي في حالة نشطة فقط',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      '/prescriptions/edit',
      arguments: {
        'id': prescription.value!.id,
        'title': prescription.value!.title,
        'customerName': prescription.value!.customerName,
        'notes': prescription.value!.notes,
        'isEditing': true,
      },
    );
  }

  // Marquer comme complétée
  Future<void> markAsCompleted() async {
    if (prescription.value == null || prescription.value!.id == null) return;

    if (prescription.value!.status != Prescription.STATUS_ACTIVE) {
      Get.snackbar(
        'غير مسموح',
        'يمكن تحديد الوصفات التي في حالة نشطة فقط كمكتملة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Demander confirmation
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('تأكيد الإكمال'),
            content: const Text('هل تريد تحديد هذه الوصفة كمكتملة؟'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    isLoading.value = true;

    try {
      final result = await _prescriptionRepository.changePrescriptionStatus(
        prescription.value!.id!,
        Prescription.STATUS_COMPLETED,
      );

      if (result) {
        // Recharger l'ordonnance pour afficher le nouveau statut
        await loadPrescription();

        Get.snackbar(
          'نجاح',
          'تم تحديد الوصفة كمكتملة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تحديد الوصفة كمكتملة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديد الوصفة كمكتملة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Annuler l'ordonnance
  Future<void> cancelPrescription() async {
    if (prescription.value == null || prescription.value!.id == null) return;

    if (prescription.value!.status != Prescription.STATUS_ACTIVE) {
      Get.snackbar(
        'غير مسموح',
        'يمكن إلغاء الوصفات التي في حالة نشطة فقط',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Demander confirmation
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('تأكيد الإلغاء'),
            content: const Text('هل أنت متأكد من إلغاء هذه الوصفة؟'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('رجوع'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('إلغاء الوصفة'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    isLoading.value = true;

    try {
      final result = await _prescriptionRepository.changePrescriptionStatus(
        prescription.value!.id!,
        Prescription.STATUS_CANCELLED,
      );

      if (result) {
        // Recharger l'ordonnance pour afficher le nouveau statut
        await loadPrescription();

        Get.snackbar(
          'نجاح',
          'تم إلغاء الوصفة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في إلغاء الوصفة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إلغاء الوصفة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Convertir en facture
  Future<void> convertToInvoice() async {
    if (prescription.value == null || prescription.value!.id == null) return;

    if (prescription.value!.status != Prescription.STATUS_ACTIVE) {
      Get.snackbar(
        'غير مسموح',
        'يمكن تحويل الوصفات التي في حالة نشطة فقط إلى فواتير',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Demander confirmation
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('تحويل إلى فاتورة'),
            content: const Text('هل تريد تحويل هذه الوصفة الطبية إلى فاتورة؟'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('تحويل'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    // Afficher un dialogue de progression
    Get.dialog(
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحويل الوصفة الطبية إلى فاتورة...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Convertir en facture
      final conversionResult = await _prescriptionRepository.convertToInvoice(
        prescription.value!.id!,
      );

      // Fermer le dialogue de progression
      Get.back();

      if (conversionResult['success']) {
        // Créer la facture
        final invoiceCreated = await _invoiceRepository.createInvoiceFromData(
          conversionResult['invoice_data'],
        );

        if (invoiceCreated) {
          // Mettre à jour le statut de l'ordonnance
          await _prescriptionRepository.changePrescriptionStatus(
            prescription.value!.id!,
            Prescription.STATUS_COMPLETED,
          );

          // Recharger l'ordonnance
          await loadPrescription();

          // Afficher un message de succès
          Get.snackbar(
            'نجاح',
            'تم تحويل الوصفة الطبية إلى فاتورة بنجاح',
            snackPosition: SnackPosition.BOTTOM,
          );

          // Naviguer vers la liste des factures
          Get.toNamed('/invoices');
        } else {
          Get.snackbar(
            'خطأ',
            'فشل في إنشاء الفاتورة',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'خطأ',
          conversionResult['message'] ??
              'فشل في تحويل الوصفة الطبية إلى فاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Fermer le dialogue de progression en cas d'erreur
      Get.back();

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحويل الوصفة الطبية إلى فاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
