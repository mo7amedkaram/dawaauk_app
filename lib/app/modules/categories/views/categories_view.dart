// lib/app/modules/categories/views/categories_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/search_bar.dart';
import '../controllers/categories_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/category_card.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصنيفات الأدوية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchBar(
              controller: TextEditingController(),
              onChanged: controller.updateSearchQuery,
              hintText: 'البحث في التصنيفات...',
              showFilterButton: false,
              showAiButton: false,
            ),
          ),

          // Categories list
          Expanded(
            child: controller.obx(
              (state) => _buildCategoriesList(),
              onLoading: const Loader(message: 'جاري تحميل التصنيفات...'),
              onError: (error) => ErrorView(
                message: controller.errorMessage.value,
                onRetry: controller.refreshData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshData();
      },
      child: Obx(() {
        if (controller.filteredCategories.isEmpty) {
          return const Center(
            child: Text('لا توجد تصنيفات متطابقة مع البحث'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.filteredCategories.length,
          itemBuilder: (context, index) {
            return CategoryCard(
              category: controller.filteredCategories[index],
            );
          },
        );
      }),
    );
  }
}
