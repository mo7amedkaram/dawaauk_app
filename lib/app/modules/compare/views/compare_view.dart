// lib/app/modules/compare/views/compare_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/compare_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';

class CompareView extends GetView<CompareController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('مقارنة الأدوية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: controller.obx(
        (state) => _buildContent(context),
        onLoading: Loader(message: 'جاري تحميل بيانات المقارنة...'),
        onError: (error) => ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.medications.isEmpty) {
        return Center(
          child: Text('لا توجد أدوية للمقارنة'),
        );
      }

      return Column(
        children: [
          // Compare options
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCompareOption(
                      context, 'price', 'السعر', controller.comparePrice.value),
                  _buildCompareOption(context, 'company', 'الشركة',
                      controller.compareCompany.value),
                  _buildCompareOption(context, 'indications', 'دواعي الاستعمال',
                      controller.compareIndications.value),
                  _buildCompareOption(context, 'dosage', 'الجرعة',
                      controller.compareDosage.value),
                  _buildCompareOption(context, 'sideEffects', 'الآثار الجانبية',
                      controller.compareSideEffects.value),
                ],
              ),
            ),
          ),

          // Medications list
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Medications headers
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property column
                        Container(
                          width: 120,
                          child: Text('المقارنة',
                              style: theme.textTheme.titleMedium),
                        ),

                        // Medications columns
                        ...controller.medications.map((medication) {
                          return Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            medication.tradeName,
                                            style: theme.textTheme.titleMedium,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (controller.medications.length > 2)
                                          IconButton(
                                            icon: Icon(Icons.close, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                            onPressed: () => controller
                                                .removeMedicationFromComparison(
                                                    medication.id),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      medication.scientificName,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    TextButton(
                                      child: Text('عرض التفاصيل'),
                                      onPressed: () => Get.toNamed(
                                          '/details/${medication.id}'),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        minimumSize: Size(0, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Basic info comparison
                    _buildComparisonSection(context, 'معلومات أساسية', [
                      if (controller.comparePrice.value)
                        _buildComparisonRow(
                          context,
                          'السعر',
                          controller.medications
                              .map((med) =>
                                  '${med.currentPrice.toStringAsFixed(2)} ج.م')
                              .toList(),
                          formatFunction: (med) =>
                              '${med.currentPrice.toStringAsFixed(2)} ج.م',
                          isNumeric: true,
                        ),
                      if (controller.compareCompany.value)
                        _buildComparisonRow(
                          context,
                          'الشركة',
                          controller.medications
                              .map((med) => med.company)
                              .toList(),
                        ),
                    ]),

                    SizedBox(height: 24),

                    // Details comparison (if available)
                    if (_hasAnyMedicationDetails() &&
                        (controller.compareIndications.value ||
                            controller.compareDosage.value ||
                            controller.compareSideEffects.value)) ...[
                      _buildComparisonSection(context, 'التفاصيل', [
                        if (controller.compareIndications.value)
                          _buildComparisonRow(
                            context,
                            'دواعي الاستعمال',
                            controller.medications
                                .map((med) =>
                                    med.details?.indications ?? 'غير متوفر')
                                .toList(),
                            isLongText: true,
                          ),
                        if (controller.compareDosage.value)
                          _buildComparisonRow(
                            context,
                            'الجرعة',
                            controller.medications
                                .map(
                                    (med) => med.details?.dosage ?? 'غير متوفر')
                                .toList(),
                            isLongText: true,
                          ),
                        if (controller.compareSideEffects.value)
                          _buildComparisonRow(
                            context,
                            'الآثار الجانبية',
                            controller.medications
                                .map((med) =>
                                    med.details?.sideEffects ?? 'غير متوفر')
                                .toList(),
                            isLongText: true,
                          ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCompareOption(
      BuildContext context, String category, String label, bool isSelected) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) => controller.toggleComparisonCategory(category),
        selectedColor: theme.colorScheme.primary.withOpacity(0.3),
        checkmarkColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildComparisonSection(
      BuildContext context, String title, List<Widget> rows) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String property,
    List<String> values, {
    Function(dynamic)? formatFunction,
    bool isLongText = false,
    bool isNumeric = false,
  }) {
    final theme = Theme.of(context);

    // Find min/max for numeric values to highlight
    double? minValue;
    double? maxValue;
    List<double> numericValues = [];

    if (isNumeric) {
      for (var value in values) {
        try {
          // Extract numeric part from string like "25.50 ج.م"
          final numericPart = double.parse(value.split(' ')[0]);
          numericValues.add(numericPart);

          if (minValue == null || numericPart < minValue) {
            minValue = numericPart;
          }

          if (maxValue == null || numericPart > maxValue) {
            maxValue = numericPart;
          }
        } catch (e) {
          // Skip if not parsable
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment:
            isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Property name
          Container(
            width: 120,
            child: Text(
              property,
              style: theme.textTheme.titleSmall,
            ),
          ),

          // Values for each medication
          ...List.generate(values.length, (index) {
            final value = values[index];

            // Determine if this is the min/max for highlighting
            bool isMinValue = false;
            bool isMaxValue = false;

            if (isNumeric && numericValues.isNotEmpty) {
              try {
                final numericPart = double.parse(value.split(' ')[0]);
                isMinValue = numericPart == minValue;
                isMaxValue = numericPart == maxValue;
              } catch (e) {
                // Skip if not parsable
              }
            }

            Color? textColor;
            if (isNumeric) {
              if (isMinValue) {
                textColor = Colors.green;
              } else if (isMaxValue) {
                textColor = Colors.red;
              }
            }

            return Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLongText
                    ? Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                      )
                    : Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isMinValue || isMaxValue ? FontWeight.bold : null,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _hasAnyMedicationDetails() {
    return controller.medications.any((med) => med.details != null);
  }
}
