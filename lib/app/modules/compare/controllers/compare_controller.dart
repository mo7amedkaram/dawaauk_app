// lib/app/modules/compare/controllers/compare_controller.dart
import 'package:get/get.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/medication_repository.dart';

class CompareController extends GetxController
    with StateMixin<List<Medication>> {
  final MedicationRepository medicationRepository =
      Get.find<MedicationRepository>();

  final RxList<int> medicationIds = <int>[].obs;
  final RxList<Medication> medications = <Medication>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Selected comparison categories
  final RxBool comparePrice = true.obs;
  final RxBool compareCompany = true.obs;
  final RxBool compareIndications = true.obs;
  final RxBool compareDosage = true.obs;
  final RxBool compareSideEffects = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Get medication IDs from arguments
    if (Get.arguments != null && Get.arguments['ids'] != null) {
      medicationIds.value = List<int>.from(Get.arguments['ids']);
      loadComparisonData();
    } else {
      errorMessage.value = 'معرفات الأدوية مطلوبة للمقارنة';
      change(null,
          status: RxStatus.error('Medication IDs are required for comparison'));
    }
  }

  Future<void> loadComparisonData() async {
    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      if (medicationIds.isEmpty) {
        errorMessage.value = 'لا توجد أدوية محددة للمقارنة';
        change(null, status: RxStatus.empty());
        return;
      }

      final comparisonResult =
          await medicationRepository.compareMedications(medicationIds);

      if (comparisonResult != null) {
        medications.value = comparisonResult;
        change(comparisonResult, status: RxStatus.success());
      } else {
        errorMessage.value = 'فشل تحميل بيانات المقارنة';
        change(null, status: RxStatus.error('Failed to load comparison data'));
      }
    } catch (e) {
      print('Error loading comparison data: $e');
      errorMessage.value = 'حدث خطأ أثناء تحميل بيانات المقارنة';
      change(null, status: RxStatus.error('Error loading comparison data'));
    } finally {
      isLoading(false);
    }
  }

  void toggleComparisonCategory(String category) {
    switch (category) {
      case 'price':
        comparePrice.toggle();
        break;
      case 'company':
        compareCompany.toggle();
        break;
      case 'indications':
        compareIndications.toggle();
        break;
      case 'dosage':
        compareDosage.toggle();
        break;
      case 'sideEffects':
        compareSideEffects.toggle();
        break;
    }
  }

  void removeMedicationFromComparison(int id) {
    if (medications.length <= 2) {
      Get.snackbar(
        'تنبيه',
        'يجب أن تقارن دواءين على الأقل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    medicationIds.remove(id);
    medications.removeWhere((med) => med.id == id);
    update();
  }

  void refreshData() {
    loadComparisonData();
  }
}
