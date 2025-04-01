// lib/app/modules/details/views/details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/medication_model.dart';
import '../controllers/details_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/medication_card.dart';

class DetailsView extends GetView<DetailsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.medication.value != null
            ? Text(controller.medication.value!.tradeName)
            : Text('تفاصيل الدواء')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
              Get.snackbar(
                'مشاركة',
                'تم نسخ رابط الدواء إلى الحافظة',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: controller.obx(
        (state) => _buildContent(context),
        onLoading: Loader(message: 'جاري تحميل التفاصيل...'),
        onError: (error) => ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        ),
      ),
      floatingActionButton: Obx(() => controller.showCompareButton.value
          ? FloatingActionButton.extended(
              onPressed: controller.goToCompare,
              icon: Icon(Icons.compare_arrows),
              label: Text('مقارنة (${controller.medicationsToCompare.length})'),
              tooltip: 'مقارنة الأدوية المحددة',
            )
          : SizedBox.shrink()),
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadMedicationDetails();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Medication info card
            _buildMedicationInfoCard(context),

            // Tabs
            _buildTabsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfoCard(BuildContext context) {
    final medication = controller.medication.value!;
    final theme = Theme.of(context);
    final hasDiscount = medication.oldPrice != null &&
        medication.oldPrice! > medication.currentPrice;

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medication.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),

            // Trade name
            Text(
              medication.tradeName,
              style: theme.textTheme.displaySmall,
            ),
            SizedBox(height: 8),

            // Scientific name
            Row(
              children: [
                Text(
                  'المادة الفعالة:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  medication.scientificName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Company
            Row(
              children: [
                Text(
                  'الشركة المصنعة:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  medication.company,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            Divider(height: 24),

            // Price section
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'السعر:',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(width: 8),

                // Current price
                Text(
                  '${medication.currentPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'د.ك',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),

                // Show old price if there's a discount
                if (hasDiscount) ...[
                  SizedBox(width: 12),
                  Text(
                    '${medication.oldPrice!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.error,
                    ),
                  ),

                  // Discount percentage
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '-${(((medication.oldPrice! - medication.currentPrice) / medication.oldPrice!) * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Obx(() {
          return Container(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabItem(context, 0, 'التفاصيل'),
                _buildTabItem(context, 1, 'البدائل المكافئة'),
                _buildTabItem(context, 2, 'البدائل'),
                _buildTabItem(context, 3, 'البدائل العلاجية'),
              ],
            ),
          );
        }),

        // Tab content
        Obx(() {
          switch (controller.currentTab.value) {
            case 0:
              return _buildDetailsTab(context);
            case 1:
              return _buildEquivalentMedicationsTab(context);
            case 2:
              return _buildAlternativesTab(context);
            case 3:
              return _buildTherapeuticAlternativesTab(context);
            default:
              return _buildDetailsTab(context);
          }
        }),
      ],
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String title) {
    final isSelected = controller.currentTab.value == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        margin: EdgeInsets.only(right: 16),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    final medication = controller.medication.value!;
    final details = medication.details;
    final theme = Theme.of(context);

    if (details == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text('لا توجد تفاصيل متاحة لهذا الدواء'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.indications != null) ...[
            _buildDetailSection(
                context, 'دواعي الاستعمال', details.indications!),
            SizedBox(height: 16),
          ],
          if (details.dosage != null) ...[
            _buildDetailSection(context, 'الجرعة', details.dosage!),
            SizedBox(height: 16),
          ],
          if (details.sideEffects != null) ...[
            _buildDetailSection(
                context, 'الآثار الجانبية', details.sideEffects!),
            SizedBox(height: 16),
          ],
          if (details.contraindications != null) ...[
            _buildDetailSection(
                context, 'موانع الاستعمال', details.contraindications!),
            SizedBox(height: 16),
          ],
          if (details.interactions != null) ...[
            _buildDetailSection(
                context, 'التفاعلات الدوائية', details.interactions!),
            SizedBox(height: 16),
          ],
          if (details.storageInfo != null) ...[
            _buildDetailSection(
                context, 'معلومات التخزين', details.storageInfo!),
            SizedBox(height: 16),
          ],
          if (details.usageInstructions != null) ...[
            _buildDetailSection(
                context, 'إرشادات الاستخدام', details.usageInstructions!),
            SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForDetailSection(title),
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForDetailSection(String title) {
    switch (title) {
      case 'دواعي الاستعمال':
        return Icons.medical_services;
      case 'الجرعة':
        return Icons.timer;
      case 'الآثار الجانبية':
        return Icons.warning;
      case 'موانع الاستعمال':
        return Icons.block;
      case 'التفاعلات الدوائية':
        return Icons.sync_alt;
      case 'معلومات التخزين':
        return Icons.inventory_2;
      case 'إرشادات الاستخدام':
        return Icons.info;
      default:
        return Icons.info;
    }
  }

  Widget _buildEquivalentMedicationsTab(BuildContext context) {
    return _buildMedicationsListTab(context, controller.equivalentMedications,
        'البدائل المكافئة', 'لا توجد بدائل مكافئة متاحة لهذا الدواء');
  }

  Widget _buildAlternativesTab(BuildContext context) {
    return _buildMedicationsListTab(context, controller.alternatives, 'البدائل',
        'لا توجد بدائل متاحة لهذا الدواء');
  }

  Widget _buildTherapeuticAlternativesTab(BuildContext context) {
    return _buildMedicationsListTab(context, controller.therapeuticAlternatives,
        'البدائل العلاجية', 'لا توجد بدائل علاجية متاحة لهذا الدواء');
  }

  Widget _buildMedicationsListTab(BuildContext context,
      RxList<Medication> medications, String title, String emptyMessage) {
    if (medications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(emptyMessage),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '$title (${medications.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Spacer(),
              if (medications.length > 1)
                ElevatedButton.icon(
                  onPressed: controller.goToCompare,
                  icon: Icon(Icons.compare_arrows, size: 18),
                  label: Text('مقارنة الكل'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            final isSelected =
                controller.medicationsToCompare.contains(medication);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: MedicationCard(
                medication: medication,
                showActions: true,
                isSelected: isSelected,
                onSelect: () =>
                    controller.toggleMedicationForComparison(medication),
              ),
            );
          },
        ),
      ],
    );
  }
}
