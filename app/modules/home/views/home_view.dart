// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/medication_card.dart';
import '../../../components/category_card.dart';
import '../../../theme/theme_controller.dart';
import '../../../routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('قاعدة بيانات الأدوية'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: themeController.toggleTheme,
            tooltip:
                themeController.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
          ),
        ],
      ),
      body: controller.obx(
        (state) => _buildContent(context),
        onLoading: Loader(message: 'جاري تحميل البيانات...'),
        onError: (error) => ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        tooltip: 'البحث',
        onPressed: () => Get.toNamed(Routes.SEARCH),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadHomeData();
      },
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Search bar
          _buildSearchBar(context),
          SizedBox(height: 24),

          // Categories section
          _buildSectionHeader(context, 'التصنيفات', 'عرض الكل', () {
            Get.toNamed(Routes.CATEGORIES);
          }),
          SizedBox(height: 16),
          _buildCategoriesGrid(),
          SizedBox(height: 24),

          // Trending medications section
          _buildSectionHeader(context, 'الأدوية الشائعة', 'عرض المزيد', () {
            Get.toNamed(Routes.SEARCH, arguments: {'sort': 'visits_desc'});
          }),
          SizedBox(height: 16),
          _buildTrendingMedications(),
          SizedBox(height: 24),

          // Most visited medications section
          _buildSectionHeader(context, 'الأكثر زيارة', 'المزيد', () {
            Get.toNamed(Routes.STATISTICS);
          }),
          SizedBox(height: 16),
          _buildMostVisitedMedications(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.SEARCH),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Theme.of(context).hintColor),
            SizedBox(width: 12),
            Text(
              'ابحث عن دواء...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return Obx(() {
      final categories = controller.categories;

      if (categories.isEmpty) {
        return Center(
          child: Text('لا توجد تصنيفات متاحة'),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length > 4 ? 4 : categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(category: categories[index]);
        },
      );
    });
  }

  Widget _buildTrendingMedications() {
    return Obx(() {
      final medications = controller.trendingMedications;

      if (medications.isEmpty) {
        return Center(
          child: Text('لا توجد أدوية شائعة متاحة'),
        );
      }

      return Container(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: medications.length,
          itemBuilder: (context, index) {
            return Container(
              width: 220,
              margin: EdgeInsets.only(right: 12),
              child: MedicationCard(
                medication: medications[index],
                showActions: false,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMostVisitedMedications() {
    return Obx(() {
      final medications = controller.mostVisitedMedications;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: medications.length > 3 ? 3 : medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => Get.toNamed('/details/${medication.id}'),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Rank circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Medication info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.tradeName,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            medication.scientificName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Visit count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${medication.visitCount}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'زيارة',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // Home is selected
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Get.toNamed(Routes.SEARCH);
            break;
          case 2:
            Get.toNamed(Routes.CATEGORIES);
            break;
          case 3:
            Get.toNamed(Routes.STATISTICS);
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'البحث',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'التصنيفات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'الإحصائيات',
        ),
      ],
    );
  }
}
