// lib/app/modules/user_guide/views/user_guide_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/user_guide_controller.dart';

class UserGuideView extends GetView<UserGuideController> {
  const UserGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageController = PageController();

    // Observer les changements de page dans le contrôleur
    ever(controller.currentPage, (page) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل المستخدم'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contenu principal
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: controller.sections.length,
              onPageChanged: (index) => controller.currentPage.value = index,
              itemBuilder: (context, index) {
                final section = controller.sections[index];
                return _buildGuidePage(context, section);
              },
            ),
          ),

          // Navigation et indicateurs
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Indicateur de page
                SmoothPageIndicator(
                  controller: pageController,
                  count: controller.sections.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.colorScheme.primary.withOpacity(0.3),
                    dotHeight: 8.r,
                    dotWidth: 8.r,
                    expansionFactor: 3,
                  ),
                ),
                SizedBox(height: 16.h),

                // Boutons de navigation
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bouton précédent
                        Visibility(
                          visible: !controller.isFirstPage,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: TextButton.icon(
                            onPressed: controller.isFirstPage
                                ? null
                                : controller.previousPage,
                            icon: Icon(Icons.arrow_back_ios, size: 16.r),
                            label: const Text('السابق'),
                          ),
                        ),

                        // Bouton suivant ou terminer
                        if (controller.isLastPage)
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.check),
                            label: const Text('إنهاء'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.r, vertical: 12.r),
                            ),
                          )
                        else
                          TextButton.icon(
                            onPressed: controller.nextPage,
                            icon: const Text('التالي'),
                            label: Icon(Icons.arrow_forward_ios, size: 16.r),
                          ),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construction d'une page du guide
  Widget _buildGuidePage(BuildContext context, GuideSection section) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône de la section
          Image.asset(
            section.icon,
            width: 120.r,
            height: 120.r,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.help_outline,
              size: 120.r,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),

          // Titre
          Text(
            section.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // Description
          Text(
            section.description,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Étapes (si disponibles)
          if (section.steps != null && section.steps!.isNotEmpty) ...[
            Text(
              'الخطوات:',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 16.h),
            ...section.steps!.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        step,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],

          // Image de la section (si disponible)
          if (section.imagePath != null) ...[
            SizedBox(height: 24.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                section.imagePath!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180.h,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
