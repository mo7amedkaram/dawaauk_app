// lib/app/components/filter_drawer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterDrawer extends StatelessWidget {
  final List<String> categories;
  final List<String> companies;
  final List<String> scientificNames;
  final String selectedCategory;
  final String selectedCompany;
  final String selectedScientificName;
  final RangeValues priceRange;
  final String selectedSortOption;
  final List<Map<String, String>> sortOptions;
  final Function(String) onCategoryChanged;
  final Function(String) onCompanyChanged;
  final Function(String) onScientificNameChanged;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(String) onSortOptionChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const FilterDrawer({
    Key? key,
    required this.categories,
    required this.companies,
    required this.scientificNames,
    required this.selectedCategory,
    required this.selectedCompany,
    required this.selectedScientificName,
    required this.priceRange,
    required this.selectedSortOption,
    required this.sortOptions,
    required this.onCategoryChanged,
    required this.onCompanyChanged,
    required this.onScientificNameChanged,
    required this.onPriceRangeChanged,
    required this.onSortOptionChanged,
    required this.onApply,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  SizedBox(width: 12),
                  Text(
                    'الفلاتر',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: onReset,
                    child: Text('إعادة ضبط'),
                  ),
                ],
              ),
            ),

            // Filter content
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Sort by
                  Text(
                    'ترتيب حسب',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedSortOption,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: sortOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Text(option['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onSortOptionChanged(value);
                    },
                  ),
                  SizedBox(height: 24),

                  // Category filter
                  Text(
                    'التصنيف',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory.isEmpty ? null : selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'اختر التصنيف',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('جميع التصنيفات'),
                      ),
                      ...categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      onCategoryChanged(value ?? '');
                    },
                  ),
                  SizedBox(height: 24),

                  // Company filter
                  Text(
                    'الشركة المصنعة',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCompany.isEmpty ? null : selectedCompany,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'اختر الشركة',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('جميع الشركات'),
                      ),
                      ...companies.map((company) {
                        return DropdownMenuItem<String>(
                          value: company,
                          child: Text(company),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      onCompanyChanged(value ?? '');
                    },
                    isExpanded: true,
                  ),
                  SizedBox(height: 24),

                  // Scientific name filter
                  Text(
                    'المادة الفعالة',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedScientificName.isEmpty
                        ? null
                        : selectedScientificName,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'اختر المادة الفعالة',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('جميع المواد الفعالة'),
                      ),
                      ...scientificNames.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      onScientificNameChanged(value ?? '');
                    },
                    isExpanded: true,
                  ),
                  SizedBox(height: 24),

                  // Price range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نطاق السعر',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '${priceRange.start.toStringAsFixed(1)} - ${priceRange.end.toStringAsFixed(1)} د.ك',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  RangeSlider(
                    values: priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    labels: RangeLabels(
                      '${priceRange.start.toStringAsFixed(1)} د.ك',
                      '${priceRange.end.toStringAsFixed(1)} د.ك',
                    ),
                    onChanged: onPriceRangeChanged,
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Apply button
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onApply();
                  Get.back(); // Close drawer
                },
                child: Text('تطبيق الفلاتر'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
