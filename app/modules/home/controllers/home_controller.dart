// lib/app/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/medication_repository.dart';

class HomeController extends GetxController with StateMixin<dynamic> {
  final MedicationRepository medicationRepository =
      Get.find<MedicationRepository>();
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();
  final StatisticsRepository statisticsRepository =
      Get.find<StatisticsRepository>();

  final RxList<Medication> trendingMedications = <Medication>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Medication> mostVisitedMedications = <Medication>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      // Load trending medications (using search with default parameters)
      final searchResponse = await medicationRepository.searchMedications(
        limit: 10,
        sort: 'visits_desc',
      );

      if (searchResponse != null) {
        trendingMedications.value = searchResponse.results;
      }

      // Load categories
      final categoriesResponse = await categoryRepository.getCategories();
      if (categoriesResponse != null) {
        categories.value = categoriesResponse;
      }

      // Load statistics for most visited medications
      final statisticsResponse = await statisticsRepository.getStatistics();
      if (statisticsResponse != null) {
        mostVisitedMedications.value =
            statisticsResponse.mostVisited.take(5).toList();
      }

      change(null, status: RxStatus.success());
    } catch (e) {
      print('Error loading home data: $e');
      errorMessage.value =
          'حدث خطأ أثناء تحميل البيانات. يرجى المحاولة مرة أخرى.';
      change(null, status: RxStatus.error('Failed to load home data.'));
    } finally {
      isLoading(false);
    }
  }

  void refreshData() {
    loadHomeData();
  }
}
