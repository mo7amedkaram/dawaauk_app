// lib/app/modules/favorites/controllers/favorites_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../../data/models/medication_model.dart';

class FavoritesController extends GetxController
    with StateMixin<List<Medication>> {
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  // Liste des médicaments favoris
  RxList<Medication> get favorites => _favoritesRepository.favorites;

  // État de chargement
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // Charger les favoris
  Future<void> loadFavorites() async {
    isLoading.value = true;
    change(null, status: RxStatus.loading());

    try {
      await _favoritesRepository.loadFavorites();

      if (favorites.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(favorites, status: RxStatus.success());
      }
    } catch (e) {
      change(null, status: RxStatus.error('حدث خطأ أثناء تحميل المفضلة'));
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter un médicament aux favoris
  Future<bool> addToFavorites(int medicationId) async {
    return await _favoritesRepository.addToFavorites(medicationId);
  }

  // Supprimer un médicament des favoris
  Future<bool> removeFromFavorites(int medicationId) async {
    return await _favoritesRepository.removeFromFavorites(medicationId);
  }

  // Vérifier si un médicament est en favoris
  Future<bool> isFavorite(int medicationId) async {
    return await _favoritesRepository.isFavorite(medicationId);
  }
}
