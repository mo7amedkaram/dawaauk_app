// lib/app/modules/sync/views/sync_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../controllers/sync_controller.dart';

class SyncView extends GetView<SyncController> {
  const SyncView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مزامنة قاعدة البيانات'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        // Si une synchronisation est en cours, afficher l'écran de progression
        if (controller.isSyncing.value) {
          return _buildSyncInProgressView(context);
        }

        // Sinon, afficher l'écran normal
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration animée
              Center(
                child: LottieBuilder.asset(
                  'assets/animations/database_sync.json',
                  width: 200.r,
                  height: 200.r,
                  frameRate: FrameRate(60),
                ),
              ),
              SizedBox(height: 24.h),

              // Carte d'information
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // État actuel
                      Row(
                        children: [
                          Icon(
                            controller.hasDatabaseDownloaded.value
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: controller.hasDatabaseDownloaded.value
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            controller.hasDatabaseDownloaded.value
                                ? 'قاعدة البيانات متوفرة'
                                : 'قاعدة البيانات غير متوفرة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Dernière mise à jour
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: theme.colorScheme.secondary),
                          SizedBox(width: 8.w),
                          Text('آخر تحديث: ', style: theme.textTheme.bodyLarge),
                          Text(
                            controller.lastSyncDateText.value,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Séparateur
                      Divider(height: 32.h),

                      // Explication
                      Text(
                        'تعمل قاعدة البيانات المحلية على تسريع البحث وتمكين استخدام التطبيق بدون اتصال بالإنترنت. يوصى بتحديث قاعدة البيانات بشكل دوري للحصول على أحدث المعلومات والأسعار.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Boutons
              if (!controller.hasDatabaseDownloaded.value)
                ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.downloadFullDatabase,
                  icon: const Icon(Icons.download),
                  label: const Text('تحميل قاعدة البيانات كاملة'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.updateDatabase,
                  icon: const Icon(Icons.update),
                  label: const Text('تحديث قاعدة البيانات'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),

              SizedBox(height: 16.h),

              // Note d'avertissement
              if (controller.hasDatabaseDownloaded.value)
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'التحديث سيقوم بتنزيل الأدوية والأسعار الجديدة فقط ولن يقوم بتنزيل قاعدة البيانات بالكامل مرة أخرى.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (controller.isLoading.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const LinearProgressIndicator(),
                ),
            ],
          ),
        );
      }),
    );
  }

  // Vue pendant la synchronisation
  Widget _buildSyncInProgressView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration animée
            LottieBuilder.asset(
              'assets/animations/syncing.json',
              width: 150.r,
              height: 150.r,
              frameRate: FrameRate(60),
            ),
            SizedBox(height: 32.h),

            // Statut actuel
            Text(
              controller.syncStatus.value,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Barre de progression
            Obx(() => LinearProgressIndicator(
                  value: controller.syncProgress.value,
                  minHeight: 10.h,
                  borderRadius: BorderRadius.circular(5.r),
                )),
            SizedBox(height: 16.h),

            // Pourcentage
            Text(
              '${(controller.syncProgress.value * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),

            // Message d'information
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'يرجى عدم إغلاق التطبيق أو قطع الاتصال بالإنترنت أثناء عملية التزامن.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
