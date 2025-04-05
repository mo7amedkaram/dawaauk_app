// lib/app/modules/prescription_details/views/prescription_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../data/models/prescription_model.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../controller/prescription_details_controller.dart';

class PrescriptionDetailsView extends GetView<PrescriptionDetailsController> {
  const PrescriptionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الوصفة الطبية'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Menu d'options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  controller.editPrescription();
                  break;
                case 'complete':
                  controller.markAsCompleted();
                  break;
                case 'cancel':
                  controller.cancelPrescription();
                  break;
                case 'convert':
                  controller.convertToInvoice();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (controller.prescription.value?.status ==
                  Prescription.STATUS_ACTIVE)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: theme.iconTheme.color),
                      SizedBox(width: 8.w),
                      const Text('تعديل الوصفة'),
                    ],
                  ),
                ),
              if (controller.prescription.value?.status ==
                  Prescription.STATUS_ACTIVE)
                PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8.w),
                      const Text('تحديد كمكتملة'),
                    ],
                  ),
                ),
              if (controller.prescription.value?.status ==
                  Prescription.STATUS_ACTIVE)
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text('إلغاء الوصفة'),
                    ],
                  ),
                ),
              if (controller.prescription.value?.status ==
                  Prescription.STATUS_ACTIVE)
                PopupMenuItem(
                  value: 'convert',
                  child: Row(
                    children: [
                      const Icon(Icons.receipt, color: Colors.blue),
                      SizedBox(width: 8.w),
                      const Text('تحويل إلى فاتورة'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loader(message: 'جاري تحميل تفاصيل الوصفة الطبية...');
        }

        if (controller.prescription.value == null) {
          return ErrorView(
            message: 'تعذر تحميل تفاصيل الوصفة الطبية',
            onRetry: controller.loadPrescription,
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de l'ordonnance
              _buildPrescriptionHeader(context),
              SizedBox(height: 24.h),

              // Informations du patient
              _buildPatientInfo(context),
              SizedBox(height: 24.h),

              // Liste des médicaments
              _buildMedicationsList(context),
              SizedBox(height: 24.h),

              // Notes (si présentes)
              if (controller.prescription.value?.notes != null &&
                  controller.prescription.value!.notes!.isNotEmpty)
                _buildNotesSection(context),

              // Bouton d'action flottant contextualisé
              if (controller.prescription.value?.status ==
                  Prescription.STATUS_ACTIVE)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: controller.convertToInvoice,
                      icon: const Icon(Icons.receipt),
                      label: const Text('تحويل إلى فاتورة'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.r, vertical: 12.h),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // En-tête de l'ordonnance
  Widget _buildPrescriptionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final prescription = controller.prescription.value!;
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
                      'وصفة طبية ${prescription.id}#',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      prescription.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                _buildStatusBadge(context, prescription.status),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18.r, color: theme.colorScheme.secondary),
                SizedBox(width: 8.w),
                Text(
                  'تاريخ الإنشاء: ${dateFormatter.format(prescription.dateCreated)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Informations du patient
  Widget _buildPatientInfo(BuildContext context) {
    final theme = Theme.of(context);
    final prescription = controller.prescription.value!;

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
              'بيانات المريض',
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
                  prescription.customerName,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Liste des médicaments
  Widget _buildMedicationsList(BuildContext context) {
    final theme = Theme.of(context);
    final prescription = controller.prescription.value!;

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
              'الأدوية الموصوفة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescription.items.length,
              itemBuilder: (context, index) {
                final item = prescription.items[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 16.r),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du médicament
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.medication,
                              color: theme.colorScheme.primary),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.medication?.tradeName ??
                                      'دواء غير معروف',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.medication?.scientificName != null)
                                  Text(
                                    item.medication!.scientificName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.r, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3)),
                            ),
                            child: Text(
                              'الكمية: ${item.quantity}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Dosage et durée
                      if (item.dosage != null && item.dosage!.isNotEmpty)
                        _buildMedicationInfoRow(
                          context,
                          'الجرعة:',
                          item.dosage!,
                          Icons.timer,
                        ),

                      if (item.duration != null && item.duration!.isNotEmpty)
                        _buildMedicationInfoRow(
                          context,
                          'المدة:',
                          item.duration!,
                          Icons.date_range,
                        ),

                      // Instructions
                      if (item.instructions != null &&
                          item.instructions!.isNotEmpty)
                        _buildMedicationInfoRow(
                          context,
                          'التعليمات:',
                          item.instructions!,
                          Icons.info_outline,
                        ),

                      // Bouton pour voir les détails du médicament
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            if (item.medication != null) {
                              Get.toNamed('/details/${item.medication!.id}');
                            }
                          },
                          icon: Icon(Icons.visibility, size: 18.r),
                          label: const Text('عرض تفاصيل الدواء'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
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

  // Rangée d'information sur un médicament
  Widget _buildMedicationInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: theme.colorScheme.secondary),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section des notes
  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);
    final prescription = controller.prescription.value!;

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
              prescription.notes!,
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
}
