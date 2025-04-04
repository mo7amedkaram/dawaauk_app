// lib/app/modules/statistics/controllers/statistics_controller.dart
import 'package:get/get.dart';
import 'package:medication_database/app/data/repositories/medication_repository.dart';
import '../../../data/models/medication_model.dart';

class StatisticsController extends GetxController
    with StateMixin<StatisticsResponse> {
  final StatisticsRepository statisticsRepository =
      Get.find<StatisticsRepository>();

  final Rx<StatisticsResponse?> statistics = Rx<StatisticsResponse?>(null);
  final RxList<Medication> mostVisitedMedications = <Medication>[].obs;
  final RxList<Medication> mostSearchedMedications = <Medication>[].obs;
  final RxList<SearchTerm> topSearchTerms = <SearchTerm>[].obs;
  final Rx<GeneralStats?> generalStats = Rx<GeneralStats?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedPeriod =
      0.obs; // 0 = all time, 1 = month, 2 = week, 3 = day

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      final result = await statisticsRepository.getStatistics();

      if (result != null) {
        statistics.value = result;
        mostVisitedMedications.value = result.mostVisited;
        mostSearchedMedications.value = result.mostSearched;
        topSearchTerms.value = result.topSearchTerms;
        generalStats.value = result.generalStats;

        change(result, status: RxStatus.success());
      } else {
        errorMessage.value = 'فشل تحميل الإحصائيات';
        change(null, status: RxStatus.error('Failed to load statistics'));
      }
    } catch (e) {
      print('Error loading statistics: $e');
      errorMessage.value = 'حدث خطأ أثناء تحميل الإحصائيات';
      change(null, status: RxStatus.error('Error loading statistics'));
    } finally {
      isLoading(false);
    }
  }

  void changePeriod(int period) {
    selectedPeriod.value = period;
    // In a real app, we'd re-fetch data with the period parameter
    // For now, we'll simulate by refreshing the data
    loadStatistics();
  }

  void refreshData() {
    loadStatistics();
  }
}
