// lib/app/modules/category_details/views/category_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_details_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/medication_card.dart';

class CategoryDetailsView extends GetView<CategoryDetailsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.category.value != null
            ? Text(controller.category.value!.arabicName)
            : Text('تفاصيل التصنيف')),
        centerTitle: true,
        elevation: 0,
      ),
      body: controller.obx(
        (state) => _buildContent(context),
        onLoading: Loader(message: 'جاري تحميل البيانات...'),
        onError: (error) => ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadCategoryDetails();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category info card
            _buildCategoryInfoCard(context),

            // Medications list
            _buildMedicationsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfoCard(BuildContext context) {
    final category = controller.category.value!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name
            Text(
              category.arabicName,
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: 4),
            Text(
              category.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Divider(height: 24),

            // Category description
            Text(
              category.description,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList(BuildContext context) {
    return Obx(() {
      final medications = controller.medications;

      if (medications.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text('لا توجد أدوية في هذا التصنيف'),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأدوية (${controller.totalMedications})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.toNamed('/search', arguments: {
                      'category': controller.category.value!.name,
                    });
                  },
                  icon: Icon(Icons.filter_list, size: 18),
                  label: Text('فلترة'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MedicationCard(
                  medication: medications[index],
                  showActions: true,
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
