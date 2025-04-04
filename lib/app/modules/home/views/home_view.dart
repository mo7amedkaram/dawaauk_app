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
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;
    final theme = Theme.of(context);

    // معلومات حول حجم الشاشة للتجاوب
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 600;

    // تعديل الهوامش والأحجام بناءً على حجم الشاشة
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("دواؤك"),
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
    // معلومات حول حجم الشاشة للتجاوب
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // تعديل الهوامش والأحجام بناءً على حجم الشاشة
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalSpacing = isSmallScreen ? 16.0 : 24.0;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadHomeData();
      },
      child: ListView(
        padding: EdgeInsets.all(horizontalPadding),
        children: [
          // Search bar
          _buildSearchBar(context),
          SizedBox(height: verticalSpacing),

          // Categories section
          _buildSectionHeader(context, 'التصنيفات', 'عرض الكل', () {
            Get.toNamed(Routes.CATEGORIES);
          }),
          SizedBox(height: 16),
          _buildCategoriesGrid(context),
          SizedBox(height: verticalSpacing),

          // Trending medications section
          _buildSectionHeader(context, 'الأدوية الشائعة', 'عرض المزيد', () {
            Get.toNamed(Routes.SEARCH, arguments: {'sort': 'visits_desc'});
          }),
          SizedBox(height: 16),
          _buildTrendingMedications(context),
          SizedBox(height: verticalSpacing),

          // Most visited medications section
          _buildSectionHeader(context, 'الأكثر زيارة', 'المزيد', () {
            Get.toNamed(Routes.STATISTICS);
          }),
          SizedBox(height: 16),
          _buildMostVisitedMedications(context),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final paddingSize = isSmallScreen ? 12.0 : 16.0;

    return InkWell(
      onTap: () => Get.toNamed(Routes.SEARCH),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingSize, vertical: 12),
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
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isSmallScreen
              ? theme.textTheme.titleMedium
              : theme.textTheme.titleLarge,
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionText),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16,
              vertical: isSmallScreen ? 4 : 8,
            ),
            minimumSize: Size(0, 0),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // تكييف عدد الأعمدة والنسبة وفقًا لعرض الشاشة
    int crossAxisCount = 2; // افتراضي
    double childAspectRatio = 0.8; // افتراضي
    double spacing = 12;

    if (screenWidth < 360) {
      crossAxisCount = 1;
      childAspectRatio = 1.2;
      spacing = 8;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

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
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: categories.length > (crossAxisCount * 2)
            ? (crossAxisCount * 2)
            : categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(category: categories[index]);
        },
      );
    });
  }

  Widget _buildTrendingMedications(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 360 ? 180.0 : 220.0;
    final cardSpacing = screenWidth < 360 ? 8.0 : 12.0;

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
              width: cardWidth,
              margin: EdgeInsets.only(right: cardSpacing),
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

  Widget _buildMostVisitedMedications(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Obx(() {
      final medications = controller.mostVisitedMedications;

      // تحسين - استخدام ListView.builder بدلاً من ListView العادي
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: medications.length > 3 ? 3 : medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Card(
            margin: EdgeInsets.only(bottom: spacing),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => Get.toNamed('/details/${medication.id}'),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                child: Row(
                  children: [
                    // Rank circle - تعديل الحجم ليناسب الشاشات الصغيرة
                    Container(
                      width: isSmallScreen ? 32 : 40,
                      height: isSmallScreen ? 32 : 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : null,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),

                    // Medication info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.tradeName,
                            style: isSmallScreen
                                ? theme.textTheme.titleSmall
                                : theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            medication.scientificName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: isSmallScreen ? 12 : null,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : null,
                          ),
                        ),
                        Text(
                          'زيارة',
                          style: theme.textTheme.bodySmall,
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
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

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
      // تحسين الأداء - تقليل حجم الخط في الشاشات الصغيرة
      selectedLabelStyle: TextStyle(
        fontSize: isSmallScreen ? 10 : 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: isSmallScreen ? 10 : 12,
      ),
    );
  }
}
