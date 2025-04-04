// lib/app/modules/category_details/controllers/category_details_controller.dart
import 'package:get/get.dart';
import 'package:medication_database/app/data/repositories/medication_repository.dart';
import '../../../data/models/medication_model.dart';

class CategoryDetailsController extends GetxController
    with StateMixin<Map<String, dynamic>> {
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();

  final RxInt categoryId = 0.obs;
  final Rx<Category?> category = Rx<Category?>(null);
  final RxList<Medication> medications = <Medication>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalMedications = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Get category ID from route parameter
    if (Get.parameters['id'] != null) {
      try {
        categoryId.value = int.parse(Get.parameters['id']!);
        loadCategoryDetails();
      } catch (e) {
        errorMessage.value = 'معرف التصنيف غير صالح';
        change(null, status: RxStatus.error('Invalid category ID'));
      }
    } else {
      errorMessage.value = 'معرف التصنيف مطلوب';
      change(null, status: RxStatus.error('Category ID is required'));
    }
  }

  Future<void> loadCategoryDetails() async {
    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      final details =
          await categoryRepository.getCategoryDetails(categoryId.value);

      if (details != null) {
        category.value = Category.fromJson(details['category']);

        // Parse medications
        if (details['medications'] != null) {
          medications.value = (details['medications'] as List)
              .map((e) => Medication.fromJson(e))
              .toList();
          totalMedications.value = details['total'] ?? medications.length;
        }

        change(details, status: RxStatus.success());
      } else {
        errorMessage.value = 'فشل تحميل تفاصيل التصنيف';
        change(null, status: RxStatus.error('Failed to load category details'));
      }
    } catch (e) {
      print('Error loading category details: $e');
      errorMessage.value = 'حدث خطأ أثناء تحميل التفاصيل';
      change(null, status: RxStatus.error('Error loading details'));
    } finally {
      isLoading(false);
    }
  }

  void refreshData() {
    loadCategoryDetails();
  }
}
