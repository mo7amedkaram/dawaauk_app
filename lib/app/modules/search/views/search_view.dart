// lib/app/modules/search/views/search_view.dart
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:medication_database/app/components/search_bar.dart';
import '../controllers/search_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/empty_view.dart';
import '../../../components/medication_card.dart';
import '../../../components/filter_drawer.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن الأدوية'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: _buildFilterDrawer(),
      body: Column(
        children: [
          // Search bar area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AppSearchBar(
              controller: controller.searchTextController,
              onChanged: (value) {
                controller.updateSearchQuery(value);
              },
              onClear: () {
                controller.searchTextController.clear();
                controller.updateSearchQuery('');
              },
              hintText:
                  'البحث عن دواء بالاسم، المادة الفعالة، أو الشركة المصنعة...',
              autoFocus: true,
              showFilterButton: true,
              onFilterTap: controller.toggleFilters,
              showAiButton: true,
              isAiEnabled: controller.isAiSearch.value,
              onAiToggle: controller.toggleAiSearch,
            ),
          ),

          // Active filters
          Obx(() {
            final hasActiveFilters = controller.selectedCategory.isNotEmpty ||
                controller.selectedCompany.isNotEmpty ||
                controller.selectedScientificName.isNotEmpty ||
                controller.priceRange.value.start > 0 ||
                controller.priceRange.value.end < 1000 ||
                controller.selectedSortOption.value != 'relevance';

            if (hasActiveFilters) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الفلاتر النشطة',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.resetFilters,
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 0),
                      ),
                      child: const Text('إعادة ضبط'),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Search results
          Expanded(
            child: controller.obx(
              (state) => _buildSearchResults(),
              onLoading: const Loader(message: 'جاري البحث...'),
              onError: (error) => ErrorView(
                message: error,
                onRetry: controller.search,
              ),
              onEmpty: EmptyView(
                message: 'لا توجد نتائج للبحث',
                actionText: 'تعديل معايير البحث',
                onAction: controller.toggleFilters,
                customWidget: LottieBuilder.asset(""),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      final results = controller.searchResults;

      if (results.isEmpty) {
        return EmptyView(
          message: 'لا توجد نتائج للبحث',
          actionText: 'تعديل معايير البحث',
          onAction: controller.toggleFilters,
          customWidget: LottieBuilder.asset(""),
        );
      }

      return Column(
        children: [
          // Results count and pagination info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'النتائج: ${controller.totalResults}',
                  style: Get.textTheme.bodyMedium,
                ),
                Text(
                  'صفحة ${controller.currentPage.value} من ${controller.totalPages.value}',
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: MedicationCard(
                    medication: results[index],
                    showActions: true,
                  ),
                );
              },
            ),
          ),

          // Pagination controls
          if (controller.totalPages.value > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: controller.currentPage.value > 1
                        ? controller.previousPage
                        : null,
                  ),
                  const SizedBox(width: 16),
                  ...List.generate(
                    controller.totalPages.value > 5
                        ? 5
                        : controller.totalPages.value,
                    (index) {
                      int pageNumber;
                      if (controller.totalPages.value <= 5) {
                        pageNumber = index + 1;
                      } else {
                        if (controller.currentPage.value <= 3) {
                          pageNumber = index + 1;
                        } else if (controller.currentPage.value >=
                            controller.totalPages.value - 2) {
                          pageNumber = controller.totalPages.value - 4 + index;
                        } else {
                          pageNumber = controller.currentPage.value - 2 + index;
                        }
                      }

                      return InkWell(
                        onTap: () => controller.goToPage(pageNumber),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.currentPage.value == pageNumber
                                ? Get.theme.colorScheme.primary
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$pageNumber',
                              style: TextStyle(
                                color:
                                    controller.currentPage.value == pageNumber
                                        ? Colors.white
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: controller.currentPage.value <
                            controller.totalPages.value
                        ? controller.nextPage
                        : null,
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildFilterDrawer() {
    return Obx(() {
      return FilterDrawer(
        categories: controller.categories,
        companies: controller.companies,
        scientificNames: controller.scientificNames,
        selectedCategory: controller.selectedCategory.value,
        selectedCompany: controller.selectedCompany.value,
        selectedScientificName: controller.selectedScientificName.value,
        priceRange: controller.priceRange.value,
        selectedSortOption: controller.selectedSortOption.value,
        sortOptions: controller.sortOptions,
        onCategoryChanged: (value) => controller.selectedCategory.value = value,
        onCompanyChanged: (value) => controller.selectedCompany.value = value,
        onScientificNameChanged: (value) =>
            controller.selectedScientificName.value = value,
        onPriceRangeChanged: (value) => controller.priceRange.value = value,
        onSortOptionChanged: (value) =>
            controller.selectedSortOption.value = value,
        onApply: controller.applyFilters,
        onReset: controller.resetFilters,
      );
    });
  }
}
