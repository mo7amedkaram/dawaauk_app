// lib/app/modules/home/views/home_view.dart (mise à jour)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/home_controller.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/medication_card.dart';
import '../../../components/category_card.dart';
import '../../../theme/theme_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/local/database_manager.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;
    final theme = Theme.of(context);
    final dbManager = Get.find<DatabaseManager>();

    // Adapter les marges et tailles en fonction de la taille de l'écran
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("دواؤك"),
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
      drawer: _buildMainDrawer(context, dbManager),
      body: controller.obx(
        (state) => _buildContent(context),
        onLoading: const Loader(message: 'جاري تحميل البيانات...'),
        onError: (error) => ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'البحث',
        onPressed: () => Get.toNamed(Routes.SEARCH),
        child: const Icon(Icons.search),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Menu latéral principal
  Widget _buildMainDrawer(BuildContext context, DatabaseManager dbManager) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // En-tête du drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دواؤك',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'قاعدة بيانات الأدوية الشاملة',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 16.h),
                // Afficher la date de dernière synchronisation
                Obx(() {
                  final lastSync = dbManager.lastSyncDate;
                  return Text(
                    lastSync != null
                        ? 'آخر تحديث: ${lastSync.day}/${lastSync.month}/${lastSync.year}'
                        : 'لم يتم التزامن بعد',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Menu principal
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('البحث'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SEARCH);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('التصنيفات'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.CATEGORIES);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('المفضلة'),
            onTap: () {
              // Suite de lib/app/modules/home/views/home_view.dart (mise à jour)

              Get.back();
              Get.toNamed(Routes.FAVORITES);
            },
          ),

          const Divider(),

          // Section gestion
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
            child: Text(
              'إدارة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('الوصفات الطبية'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.PRESCRIPTIONS);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('الفواتير'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.INVOICES);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('الإحصائيات'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.STATISTICS);
            },
          ),

          const Divider(),

          // Section outils
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
            child: Text(
              'أدوات',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('تحديث قاعدة البيانات'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.SYNC);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('دليل المستخدم'),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.USER_GUIDE);
            },
          ),

          // Section about
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('عن التطبيق'),
            onTap: () {
              Get.back();
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Contenu principal de l'écran d'accueil
  Widget _buildContent(BuildContext context) {
    // Adapter les marges et tailles en fonction de la taille de l'écran
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalSpacing = isSmallScreen ? 16.0 : 24.0;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadHomeData();
      },
      child: ListView(
        padding: EdgeInsets.all(horizontalPadding),
        children: [
          // Barre de recherche
          _buildSearchBar(context),
          SizedBox(height: verticalSpacing),

          // Cartes de raccourcis rapides
          _buildQuickAccessCards(context),
          SizedBox(height: verticalSpacing),

          // Section des catégories
          _buildSectionHeader(context, 'التصنيفات', 'عرض الكل', () {
            Get.toNamed(Routes.CATEGORIES);
          }),
          const SizedBox(height: 16),
          _buildCategoriesGrid(context),
          SizedBox(height: verticalSpacing),

          // Section des médicaments populaires
          _buildSectionHeader(context, 'الأدوية الشائعة', 'عرض المزيد', () {
            Get.toNamed(Routes.SEARCH, arguments: {'sort': 'visits_desc'});
          }),
          const SizedBox(height: 16),
          _buildTrendingMedications(context),
          SizedBox(height: verticalSpacing),

          // Section des médicaments les plus visités
          _buildSectionHeader(context, 'الأكثر زيارة', 'المزيد', () {
            Get.toNamed(Routes.STATISTICS);
          }),
          const SizedBox(height: 16),
          _buildMostVisitedMedications(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Cartes d'accès rapide
  Widget _buildQuickAccessCards(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildQuickAccessCard(
          context,
          'الوصفات الطبية',
          'إنشاء وإدارة الوصفات الطبية',
          Icons.assignment,
          Colors.blue,
          () => Get.toNamed(Routes.PRESCRIPTIONS),
        ),
        _buildQuickAccessCard(
          context,
          'الفواتير',
          'إدارة الفواتير والمبيعات',
          Icons.receipt_long,
          Colors.green,
          () => Get.toNamed(Routes.INVOICES),
        ),
        _buildQuickAccessCard(
          context,
          'المفضلة',
          'الأدوية المفضلة لديك',
          Icons.favorite,
          Colors.red,
          () => Get.toNamed(Routes.FAVORITES),
        ),
        _buildQuickAccessCard(
          context,
          'الإحصائيات',
          'تقارير وإحصائيات',
          Icons.analytics,
          Colors.purple,
          () => Get.toNamed(Routes.STATISTICS),
        ),
      ],
    );
  }

  // Carte d'accès rapide individuelle
  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 28.r,
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Theme.of(context).hintColor),
            const SizedBox(width: 12),
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
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16,
              vertical: isSmallScreen ? 4 : 8,
            ),
            minimumSize: const Size(0, 0),
          ),
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adapter le nombre de colonnes et le ratio en fonction de la largeur de l'écran
    int crossAxisCount = 2; // Par défaut
    double childAspectRatio = 0.8; // Par défaut
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
        return const Center(
          child: Text('لا توجد تصنيفات متاحة'),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
        return const Center(
          child: Text('لا توجد أدوية شائعة متاحة'),
        );
      }

      return SizedBox(
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

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                    // Rank circle - adapter la taille pour les petits écrans
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

                    // Infos du médicament
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
                          const SizedBox(height: 4),
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

                    // Nombre de visites
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
            Get.toNamed(Routes.FAVORITES);
            break;
          case 3:
            Get.toNamed(Routes.PRESCRIPTIONS);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'البحث',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'المفضلة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'الوصفات',
        ),
      ],
      // Optimiser l'affichage - réduire la taille de la police sur les petits écrans
      selectedLabelStyle: TextStyle(
        fontSize: isSmallScreen ? 10 : 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: isSmallScreen ? 10 : 12,
      ),
    );
  }

  // Afficher la boîte de dialogue "À propos"
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'دواؤك',
        applicationVersion: 'الإصدار 1.0.0',
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 48,
          height: 48,
        ),
        children: const [
          SizedBox(height: 16),
          Text(
            'تطبيق شامل لإدارة وحفظ والبحث في قاعدة بيانات الأدوية.',
          ),
          SizedBox(height: 8),
          Text(
            'تم تطويره خصيصاً للصيدليات والمؤسسات الطبية لتسهيل الوصول إلى معلومات الأدوية.',
          ),
          SizedBox(height: 16),
          Text(
            '© 2025 جميع الحقوق محفوظة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
