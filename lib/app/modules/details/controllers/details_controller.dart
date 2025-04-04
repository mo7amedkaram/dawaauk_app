// lib/app/modules/details/controllers/details_controller.dart
import 'package:get/get.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/medication_repository.dart';

class DetailsController extends GetxController
    with StateMixin<MedicationDetailResponse> {
  final MedicationRepository medicationRepository =
      Get.find<MedicationRepository>();

  final RxInt medicationId = 0.obs;
  final Rx<Medication?> medication = Rx<Medication?>(null);
  final RxList<Medication> equivalentMedications = <Medication>[].obs;
  final RxList<Medication> alternatives = <Medication>[].obs;
  final RxList<Medication> therapeuticAlternatives = <Medication>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentTab = 0.obs;

  // Selected medications for comparison
  final RxList<Medication> medicationsToCompare = <Medication>[].obs;
  final RxBool showCompareButton = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get medication ID from route parameter
    if (Get.parameters['id'] != null) {
      try {
        medicationId.value = int.parse(Get.parameters['id']!);
        loadMedicationDetails();
      } catch (e) {
        errorMessage.value = 'معرف الدواء غير صالح';
        change(null, status: RxStatus.error('Invalid medication ID'));
      }
    } else {
      errorMessage.value = 'معرف الدواء مطلوب';
      change(null, status: RxStatus.error('Medication ID is required'));
    }
  }

  Future<void> loadMedicationDetails() async {
    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      final details =
          await medicationRepository.getMedicationDetails(medicationId.value);

      if (details != null) {
        medication.value = details.medication;
        equivalentMedications.value = details.equivalentMedications;
        alternatives.value = details.alternatives;
        therapeuticAlternatives.value = details.therapeuticAlternatives;

        // Add main medication to comparison by default
        medicationsToCompare.add(details.medication);

        change(details, status: RxStatus.success());
      } else {
        errorMessage.value = 'فشل تحميل تفاصيل الدواء';
        change(null,
            status: RxStatus.error('Failed to load medication details'));
      }
    } catch (e) {
      print('Error loading medication details: $e');
      errorMessage.value = 'حدث خطأ أثناء تحميل التفاصيل';
      change(null, status: RxStatus.error('Error loading details'));
    } finally {
      isLoading(false);
    }
  }

  void changeTab(int index) {
    currentTab.value = index;
  }

  void toggleMedicationForComparison(Medication med) {
    if (medicationsToCompare.contains(med)) {
      medicationsToCompare.remove(med);
    } else {
      // Limit to 3 medications for comparison (including the main one)
      if (medicationsToCompare.length < 3) {
        medicationsToCompare.add(med);
      } else {
        Get.snackbar(
          'تنبيه',
          'يمكنك مقارنة 3 أدوية كحد أقصى',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    // Show compare button only if more than one medication is selected
    showCompareButton.value = medicationsToCompare.length > 1;
  }

  void goToCompare() {
    if (medicationsToCompare.length > 1) {
      final List<int> ids = medicationsToCompare.map((med) => med.id).toList();
      Get.toNamed('/compare', arguments: {'ids': ids});
    }
  }

  void refreshData() {
    loadMedicationDetails();
  }
}
