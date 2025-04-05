// lib/app/modules/invoices/views/invoices_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../data/models/invoice_model.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/empty_view.dart';
import '../controller/invoices_controller.dart';

class InvoicesView extends GetView<InvoicesController> {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Bouton de rapport
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'تقارير المبيعات',
            onPressed: () => Get.toNamed('/invoices/reports'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres de statut
          _buildStatusFilter(context),

          // Liste des factures
          Expanded(
            child: controller.obx(
              (state) => _buildInvoicesList(context, state),
              onLoading: const Loader(message: 'جاري تحميل الفواتير...'),
              onError: (error) => ErrorView(
                message: error,
                onRetry: controller.loadInvoices,
              ),
              onEmpty: EmptyView(
                message: 'لا توجد فواتير',
                actionText: 'إنشاء فاتورة جديدة',
                onAction: () => _showNewInvoiceDialog(context),
                customWidget: LottieBuilder.asset(""),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewInvoiceDialog(context),
        tooltip: 'إنشاء فاتورة جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Filtres de statut des factures
  Widget _buildStatusFilter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                _buildFilterChip(context, 'الكل', 'all',
                    controller.currentStatusFilter.value),
                SizedBox(width: 8.w),
                _buildFilterChip(
                    context,
                    'قيد الانتظار',
                    Invoice.STATUS_PENDING,
                    controller.currentStatusFilter.value),
                SizedBox(width: 8.w),
                _buildFilterChip(context, 'مدفوعة', Invoice.STATUS_PAID,
                    controller.currentStatusFilter.value),
                SizedBox(width: 8.w),
                _buildFilterChip(context, 'ملغاة', Invoice.STATUS_CANCELLED,
                    controller.currentStatusFilter.value),
              ],
            )),
      ),
    );
  }

  // Puce de filtre individuelle
  Widget _buildFilterChip(
      BuildContext context, String label, String value, String selectedValue) {
    final theme = Theme.of(context);
    final isSelected = selectedValue == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.changeStatusFilter(value),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
    );
  }

  // Liste des factures
  Widget _buildInvoicesList(BuildContext context, List<Invoice>? invoices) {
    if (invoices == null || invoices.isEmpty) {
      return EmptyView(
        message: 'لا توجد فواتير بهذا التصنيف',
        actionText: 'إنشاء فاتورة جديدة',
        onAction: () => _showNewInvoiceDialog(context),
        customWidget: LottieBuilder.asset(""),
      );
    }

    final dateFormatter = DateFormat('dd/MM/yyyy', 'ar');
    final currencyFormatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadInvoices();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16.r),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: InkWell(
              onTap: () => Get.toNamed(
                '/invoices/details/${invoice.id}',
                arguments: {'invoice': invoice},
              ),
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec titre et statut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            invoice.title,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(context, invoice.status),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Informations du client
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 18.r,
                            color: context.theme.colorScheme.secondary),
                        SizedBox(width: 8.w),
                        Text(
                          invoice.customerName,
                          style: context.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 18.r,
                            color: context.theme.colorScheme.secondary),
                        SizedBox(width: 8.w),
                        Text(
                          dateFormatter.format(invoice.dateCreated),
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Nombre d'articles et montant total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medication,
                                size: 18.r,
                                color: context.theme.colorScheme.secondary),
                            SizedBox(width: 8.w),
                            Text(
                              '${invoice.items.length} أدوية',
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Text(
                          currencyFormatter.format(invoice.totalAmount),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    // Notes (optionnelles)
                    if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: context.theme.dividerColor,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.note,
                                size: 18.r, color: context.theme.hintColor),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                invoice.notes!,
                                style: context.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bouton d'édition (seulement pour les factures en attente)
                        if (invoice.status == Invoice.STATUS_PENDING)
                          TextButton.icon(
                            onPressed: () => _editInvoice(context, invoice),
                            icon: Icon(Icons.edit, size: 18.r),
                            label: const Text('تعديل'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12.r),
                            ),
                          ),
                        SizedBox(width: 8.w),

                        // Bouton d'impression/exportation
                        OutlinedButton.icon(
                          onPressed: () =>
                              controller.exportInvoiceToPdf(invoice.id!),
                          icon: Icon(Icons.print, size: 18.r),
                          label: const Text('طباعة'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 12.r),
                          ),
                        ),

                        // Bouton pour marquer comme payée (seulement pour les factures en attente)
                        if (invoice.status == Invoice.STATUS_PENDING) ...[
                          SizedBox(width: 8.w),
                          ElevatedButton.icon(
                            onPressed: () => _markAsPaid(context, invoice),
                            icon: Icon(Icons.payments, size: 18.r),
                            label: const Text('دفع'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 12.r),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

  // Afficher la boîte de dialogue pour une nouvelle facture
  void _showNewInvoiceDialog(BuildContext context) {
    final titleController = TextEditingController();
    final customerNameController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إنشاء فاتورة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الفاتورة*',
                  hintText: 'مثال: فاتورة شراء أدوية',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل*',
                  hintText: 'الاسم الكامل للعميل',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  hintText: 'أي ملاحظات إضافية',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // Vérifier les champs obligatoires
              if (titleController.text.trim().isEmpty ||
                  customerNameController.text.trim().isEmpty) {
                Get.snackbar(
                  'خطأ',
                  'يرجى ملء جميع الحقول المطلوبة',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              // Préparer pour créer une nouvelle facture
              controller.prepareNewInvoice();

              // Fermer la boîte de dialogue
              Get.back();

              // Naviguer vers l'écran d'édition de facture
              Get.toNamed(
                '/invoices/edit',
                arguments: {
                  'title': titleController.text.trim(),
                  'customerName': customerNameController.text.trim(),
                  'notes': notesController.text.trim(),
                },
              );
            },
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  // Éditer une facture existante
  void _editInvoice(BuildContext context, Invoice invoice) async {
    // Vérifier que la facture est en statut "en attente"
    if (invoice.status != Invoice.STATUS_PENDING) {
      Get.snackbar(
        'غير مسموح',
        'يمكن تعديل الفواتير التي في حالة الانتظار فقط',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Charger les données pour l'édition
    await controller.loadInvoiceForEdit(invoice.id!);

    // Naviguer vers l'écran d'édition
    Get.toNamed(
      '/invoices/edit',
      arguments: {
        'id': invoice.id,
        'title': invoice.title,
        'customerName': invoice.customerName,
        'notes': invoice.notes,
        'isEditing': true,
      },
    );
  }

  // Marquer une facture comme payée
  void _markAsPaid(BuildContext context, Invoice invoice) async {
    // Demander confirmation
    final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('تأكيد الدفع'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('هل تريد تأكيد دفع هذه الفاتورة؟'),
                SizedBox(height: 12.h),
                Text(
                  'المبلغ: ${controller.formatCurrency(invoice.totalAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
                child: const Text('تأكيد الدفع'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      // Changer le statut de la facture
      final result = await controller.changeInvoiceStatus(
          invoice.id!, Invoice.STATUS_PAID);

      if (result) {
        // Rafraîchir les statistiques
        await controller.loadSalesStatistics();
      }
    }
  }
}
