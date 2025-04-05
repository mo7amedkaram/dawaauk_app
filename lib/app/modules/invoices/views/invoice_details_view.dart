// lib/app/modules/invoice_details/views/invoice_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../data/models/invoice_model.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../controller/invoice_details_controller.dart';

class InvoiceDetailsView extends GetView<InvoiceDetailsController> {
  const InvoiceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Bouton d'exportation
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'طباعة الفاتورة',
            onPressed: () => controller.exportInvoiceToPdf(),
          ),
          // Bouton de menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  controller.editInvoice();
                  break;
                case 'pay':
                  controller.markAsPaid();
                  break;
                case 'cancel':
                  controller.cancelInvoice();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (controller.invoice.value?.status == Invoice.STATUS_PENDING)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: theme.iconTheme.color),
                      SizedBox(width: 8.w),
                      const Text('تعديل الفاتورة'),
                    ],
                  ),
                ),
              if (controller.invoice.value?.status == Invoice.STATUS_PENDING)
                PopupMenuItem(
                  value: 'pay',
                  child: Row(
                    children: [
                      const Icon(Icons.payments, color: Colors.green),
                      SizedBox(width: 8.w),
                      const Text('تحديد كمدفوعة'),
                    ],
                  ),
                ),
              if (controller.invoice.value?.status == Invoice.STATUS_PENDING)
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text('إلغاء الفاتورة'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loader(message: 'جاري تحميل تفاصيل الفاتورة...');
        }

        if (controller.invoice.value == null) {
          return ErrorView(
            message: 'تعذر تحميل تفاصيل الفاتورة',
            onRetry: controller.loadInvoice,
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la facture
              _buildInvoiceHeader(context),
              SizedBox(height: 24.h),

              // Détails du client
              _buildCustomerInfo(context),
              SizedBox(height: 24.h),

              // Liste des articles
              _buildInvoiceItems(context),
              SizedBox(height: 24.h),

              // Récapitulatif des montants
              _buildInvoiceSummary(context),
              SizedBox(height: 24.h),

              // Notes (si présentes)
              if (controller.invoice.value?.notes != null &&
                  controller.invoice.value!.notes!.isNotEmpty)
                _buildNotesSection(context),
            ],
          ),
        );
      }),
    );
  }

  // En-tête de la facture
  Widget _buildInvoiceHeader(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = controller.invoice.value!;
    final dateFormatter = DateFormat('dd/MM/yyyy', 'ar');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فاتورة ${invoice.id}#',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      invoice.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                _buildStatusBadge(context, invoice.status),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18.r, color: theme.colorScheme.secondary),
                    SizedBox(width: 8.w),
                    Text(
                      'تاريخ الإصدار: ${dateFormatter.format(invoice.dateCreated)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Informations du client
  Widget _buildCustomerInfo(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = controller.invoice.value!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات العميل',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.person,
                    size: 18.r, color: theme.colorScheme.secondary),
                SizedBox(width: 8.w),
                Text(
                  'الاسم: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  invoice.customerName,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Liste des articles
  Widget _buildInvoiceItems(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = controller.invoice.value!;
    final currencyFormatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الأدوية',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // En-tête du tableau
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'الدواء',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'الكمية',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'السعر',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'الإجمالي',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste des articles
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoice.items.length,
              itemBuilder: (context, index) {
                final item = invoice.items[index];

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.medication?.tradeName ?? 'دواء غير معروف',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.medication?.scientificName != null)
                              Text(
                                item.medication!.scientificName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormatter.format(item.pricePerUnit),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          currencyFormatter.format(item.totalPrice),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Récapitulatif des montants
  Widget _buildInvoiceSummary(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = controller.invoice.value!;
    final currencyFormatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص الفاتورة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي الفاتورة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyFormatter.format(invoice.totalAmount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Section des notes
  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);
    final invoice = controller.invoice.value!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملاحظات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              invoice.notes!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // Badge de statut
  Widget _buildStatusBadge(BuildContext context, String status) {
    late Color color;
    late String label;

    switch (status) {
      case Invoice.STATUS_PENDING:
        color = Colors.orange;
        label = 'قيد الانتظار';
        break;
      case Invoice.STATUS_PAID:
        color = Colors.green;
        label = 'مدفوعة';
        break;
      case Invoice.STATUS_CANCELLED:
        color = Colors.red;
        label = 'ملغاة';
        break;
      default:
        color = Colors.grey;
        label = 'غير معروفة';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
