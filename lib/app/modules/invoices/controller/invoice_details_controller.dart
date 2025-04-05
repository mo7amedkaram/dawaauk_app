// lib/app/modules/invoice_details/controllers/invoice_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/repositories/invoice_repository.dart';

class InvoiceDetailsController extends GetxController {
  final InvoiceRepository _invoiceRepository = Get.find<InvoiceRepository>();

  final RxInt invoiceId = 0.obs;
  final Rx<Invoice?> invoice = Rx<Invoice?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Récupérer l'ID de la facture à partir des paramètres de route
    if (Get.parameters['id'] != null) {
      try {
        invoiceId.value = int.parse(Get.parameters['id']!);
        loadInvoice();
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'معرف الفاتورة غير صالح',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else if (Get.arguments != null && Get.arguments['invoice'] != null) {
      // Si la facture a été passée directement via arguments
      invoice.value = Get.arguments['invoice'] as Invoice;
      invoiceId.value = invoice.value!.id!;
    } else {
      Get.snackbar(
        'خطأ',
        'معرف الفاتورة مطلوب',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Charger les détails de la facture
  Future<void> loadInvoice() async {
    isLoading.value = true;

    try {
      final result = await _invoiceRepository.getInvoiceById(invoiceId.value);

      if (result != null) {
        invoice.value = result;
      } else {
        Get.snackbar(
          'خطأ',
          'تعذر تحميل تفاصيل الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل تفاصيل الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Exporter la facture en PDF
  Future<void> exportInvoiceToPdf() async {
    Get.snackbar(
      'قريبا',
      'سيتم تنفيذ هذه الميزة قريبا',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Modifier la facture
  void editInvoice() {
    if (invoice.value == null) return;

    if (invoice.value!.status != Invoice.STATUS_PENDING) {
      Get.snackbar(
        'غير مسموح',
        'يمكن تعديل الفواتير التي في حالة الانتظار فقط',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      '/invoices/edit',
      arguments: {
        'id': invoice.value!.id,
        'title': invoice.value!.title,
        'customerName': invoice.value!.customerName,
        'notes': invoice.value!.notes,
        'isEditing': true,
      },
    );
  }

  // Marquer comme payée
  Future<void> markAsPaid() async {
    if (invoice.value == null || invoice.value!.id == null) return;

    if (invoice.value!.status != Invoice.STATUS_PENDING) {
      Get.snackbar(
        'غير مسموح',
        'يمكن تحديد الفواتير التي في حالة الانتظار فقط كمدفوعة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Demander confirmation
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('تأكيد الدفع'),
            content: const Text('هل تريد تأكيد دفع هذه الفاتورة؟'),
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
      final result = await _invoiceRepository.changeInvoiceStatus(
        invoice.value!.id!,
        Invoice.STATUS_PAID,
      );

      if (result) {
        // Recharger la facture pour afficher le nouveau statut
        await loadInvoice();

        Get.snackbar(
          'نجاح',
          'تم تحديد الفاتورة كمدفوعة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تحديد الفاتورة كمدفوعة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديد الفاتورة كمدفوعة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Annuler la facture
  Future<void> cancelInvoice() async {
    if (invoice.value == null || invoice.value!.id == null) return;

    if (invoice.value!.status != Invoice.STATUS_PENDING) {
      Get.snackbar(
        'غير مسموح',
        'يمكن إلغاء الفواتير التي في حالة الانتظار فقط',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Demander confirmation
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('تأكيد الإلغاء'),
            content: const Text('هل أنت متأكد من إلغاء هذه الفاتورة؟'),
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
                child: const Text('إلغاء الفاتورة'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    isLoading.value = true;

    try {
      final result = await _invoiceRepository.changeInvoiceStatus(
        invoice.value!.id!,
        Invoice.STATUS_CANCELLED,
      );

      if (result) {
        // Recharger la facture pour afficher le nouveau statut
        await loadInvoice();

        Get.snackbar(
          'نجاح',
          'تم إلغاء الفاتورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في إلغاء الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء إلغاء الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
