// lib/app/modules/categories/controllers/categories_controller.dart
import 'package:get/get.dart';
import 'package:medication_database/app/data/repositories/medication_repository.dart';
import '../../../data/models/medication_model.dart';

class CategoriesController extends GetxController
    with StateMixin<List<Category>> {
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();

  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Category> filteredCategories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();

    // Set up search filtering
    debounce(
      searchQuery,
      (_) {
        filterCategories();
      },
      time: Duration(milliseconds: 300),
    );
  }

  Future<void> loadCategories() async {
    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      final result = await categoryRepository.getCategories();

      if (result != null) {
        categories.value = result;
        filteredCategories.value = result;
        change(result, status: RxStatus.success());
      } else {
        errorMessage.value = 'فشل تحميل التصنيفات';
        change(null, status: RxStatus.error('Failed to load categories'));
      }
    } catch (e) {
      print('Error loading categories: $e');
      errorMessage.value = 'حدث خطأ أثناء تحميل التصنيفات';
      change(null, status: RxStatus.error('Error loading categories'));
    } finally {
      isLoading(false);
    }
  }

  void filterCategories() {
    if (searchQuery.isEmpty) {
      filteredCategories.value = categories;
    } else {
      filteredCategories.value = categories.where((category) {
        return category.name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            category.arabicName.contains(searchQuery) ||
            category.description.contains(searchQuery);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void refreshData() {
    loadCategories();
  }
}
