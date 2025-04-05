// lib/app/modules/prescriptions/views/prescriptions_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../data/models/prescription_model.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/empty_view.dart';
import '../controller/prescriptions_controller.dart';

class PrescriptionsView extends GetView<PrescriptionsController> {
  const PrescriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الوصفات الطبية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtres de statut
          _buildStatusFilter(context),

          // Liste des ordonnances
          Expanded(
            child: controller.obx(
              (state) => _buildPrescriptionsList(context, state),
              onLoading: const Loader(message: 'جاري تحميل الوصفات الطبية...'),
              onError: (error) => ErrorView(
                message: error,
                onRetry: controller.loadPrescriptions,
              ),
              onEmpty: EmptyView(
                message: 'لا توجد وصفات طبية',
                actionText: 'إنشاء وصفة طبية جديدة',
                onAction: () => _showNewPrescriptionDialog(context),
                customWidget: LottieBuilder.asset(""),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPrescriptionDialog(context),
        tooltip: 'إنشاء وصفة طبية جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Filtres de statut des ordonnances
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
                _buildFilterChip(context, 'نشطة', Prescription.STATUS_ACTIVE,
                    controller.currentStatusFilter.value),
                SizedBox(width: 8.w),
                _buildFilterChip(
                    context,
                    'مكتملة',
                    Prescription.STATUS_COMPLETED,
                    controller.currentStatusFilter.value),
                SizedBox(width: 8.w),
                _buildFilterChip(
                    context,
                    'ملغاة',
                    Prescription.STATUS_CANCELLED,
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

  // Liste des ordonnances
  Widget _buildPrescriptionsList(
      BuildContext context, List<Prescription>? prescriptions) {
    if (prescriptions == null || prescriptions.isEmpty) {
      return EmptyView(
        message: 'لا توجد وصفات طبية بهذا التصنيف',
        actionText: 'إنشاء وصفة طبية جديدة',
        onAction: () => _showNewPrescriptionDialog(context),
        customWidget: LottieBuilder.asset(""),
      );
    }

    final dateFormatter = DateFormat('dd/MM/yyyy', 'ar');

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadPrescriptions();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16.r),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: InkWell(
              onTap: () => Get.toNamed(
                '/prescriptions/details/${prescription.id}',
                arguments: {'prescription': prescription},
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
                            prescription.title,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(context, prescription.status),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Informations du patient
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 18.r,
                            color: context.theme.colorScheme.secondary),
                        SizedBox(width: 8.w),
                        Text(
                          prescription.customerName,
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
                          dateFormatter.format(prescription.dateCreated),
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Nombre d'articles
                    Row(
                      children: [
                        Icon(Icons.medication,
                            size: 18.r,
                            color: context.theme.colorScheme.secondary),
                        SizedBox(width: 8.w),
                        Text(
                          '${prescription.items.length} أدوية',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),

                    // Notes (optionnelles)
                    if (prescription.notes != null &&
                        prescription.notes!.isNotEmpty) ...[
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
                                prescription.notes!,
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
                        // Bouton d'édition
                        TextButton.icon(
                          onPressed: () =>
                              _editPrescription(context, prescription),
                          icon: Icon(Icons.edit, size: 18.r),
                          label: const Text('تعديل'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 12.r),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Bouton de conversion en facture
                        if (prescription.status == Prescription.STATUS_ACTIVE)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _convertToInvoice(context, prescription),
                            icon: Icon(Icons.receipt, size: 18.r),
                            label: const Text('تحويل لفاتورة'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 12.r),
                            ),
                          ),
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
      case Prescription.STATUS_ACTIVE:
        color = Colors.green;
        label = 'نشطة';
        break;
      case Prescription.STATUS_COMPLETED:
        color = Colors.blue;
        label = 'مكتملة';
        break;
      case Prescription.STATUS_CANCELLED:
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

  // Afficher la boîte de dialogue pour une nouvelle ordonnance
  void _showNewPrescriptionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final customerNameController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إنشاء وصفة طبية جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الوصفة*',
                  hintText: 'مثال: وصفة شهرية',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المريض*',
                  hintText: 'الاسم الكامل للمريض',
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

              // Préparer pour créer une nouvelle ordonnance
              controller.prepareNewPrescription();

              // Fermer la boîte de dialogue
              Get.back();

              // Naviguer vers l'écran d'édition d'ordonnance
              Get.toNamed(
                '/prescriptions/edit',
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

  // Éditer une ordonnance existante
  void _editPrescription(
      BuildContext context, Prescription prescription) async {
    // Charger les données pour l'édition
    await controller.loadPrescriptionForEdit(prescription.id!);

    // Naviguer vers l'écran d'édition
    Get.toNamed(
      '/prescriptions/edit',
      arguments: {
        'id': prescription.id,
        'title': prescription.title,
        'customerName': prescription.customerName,
        'notes': prescription.notes,
        'status': prescription.status,
        'isEditing': true,
      },
    );
  }

  // Convertir une ordonnance en facture
  void _convertToInvoice(
      BuildContext context, Prescription prescription) async {
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
                child: const Text('تحويل'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      // Afficher un dialogue de progression
      Get.dialog(
        const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Loader(message: 'جاري تحويل الوصفة الطبية إلى فاتورة...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Convertir en facture
      final result = await controller.convertToInvoice(prescription.id!);

      // Fermer le dialogue de progression
      Get.back();

      if (result) {
        // Mettre à jour le statut de l'ordonnance
        await controller.changePrescriptionStatus(
            prescription.id!, Prescription.STATUS_COMPLETED);

        // Naviguer vers la liste des factures
        Get.toNamed('/invoices');
      }
    }
  }
}
