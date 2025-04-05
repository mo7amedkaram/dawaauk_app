// lib/app/modules/favorites/views/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../components/medication_card.dart';
import '../../../components/loader.dart';
import '../../../components/error_view.dart';
import '../../../components/empty_view.dart';
import '../controller/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Bouton de recherche (pour une recherche dédiée dans les favoris)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث في المفضلة',
            onPressed: () {
              // Implémentation à ajouter
              Get.toNamed('/search', arguments: {'favorites_only': true});
            },
          ),
        ],
      ),
      body: controller.obx(
        (state) => _buildFavoritesList(context, state),
        onLoading: const Loader(message: 'جاري تحميل المفضلة...'),
        onError: (error) => ErrorView(
          message: error,
          onRetry: controller.loadFavorites,
        ),
        onEmpty: _buildEmptyView(context),
      ),
    );
  }

  // Vue de la liste des favoris
  Widget _buildFavoritesList(BuildContext context, List? medications) {
    if (medications == null || medications.isEmpty) {
      return _buildEmptyView(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadFavorites();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.r),
            child: Dismissible(
              key: Key('fav_${medication.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                // Confirmation pour supprimer des favoris
                return await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('إزالة من المفضلة'),
                        content: const Text(
                            'هل أنت متأكد من رغبتك في إزالة هذا الدواء من المفضلة؟'),
                        actions: [
                          TextButton(
                            child: const Text('إلغاء'),
                            onPressed: () => Get.back(result: false),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('إزالة'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              },
              onDismissed: (direction) {
                controller.removeFromFavorites(medication.id);

                // Afficher un snackbar avec option d'annulation
                Get.snackbar(
                  'تمت الإزالة',
                  'تم إزالة ${medication.tradeName} من المفضلة',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                  mainButton: TextButton(
                    child: const Text(
                      'تراجع',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      controller.addToFavorites(medication.id);
                    },
                  ),
                );
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.r),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 32.r,
                ),
              ),
              child: MedicationCard(
                medication: medication,
                showActions: true,
                isSelected: true,
                onSelect: () => controller.removeFromFavorites(medication.id),
              ),
            ),
          );
        },
      ),
    );
  }

  // Vue vide lorsqu'il n'y a pas de favoris
  Widget _buildEmptyView(BuildContext context) {
    return EmptyView(
      message: 'لا توجد أدوية في المفضلة',
      actionText: 'ابحث عن الأدوية',
      onAction: () => Get.toNamed('/search'),
      customWidget: Lottie.asset(
        'assets/animations/favorites_empty.json',
        width: 200.r,
        height: 200.r,
        repeat: true,
        frameRate: FrameRate(60),
      ),
    );
  }
}
