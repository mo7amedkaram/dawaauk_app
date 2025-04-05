// lib/app/modules/search/controllers/search_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/medication_repository.dart';

class SearchController extends GetxController with StateMixin<SearchResponse> {
  final MedicationRepository medicationRepository =
      Get.find<MedicationRepository>();
  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();
  final CompanyRepository companyRepository = Get.find<CompanyRepository>();
  final ScientificNameRepository scientificNameRepository =
      Get.find<ScientificNameRepository>();

  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isAiSearch = false.obs;
  final RxBool showFilters = false.obs;

  // Filter options
  final RxList<String> categories = <String>[].obs;
  final RxList<String> companies = <String>[].obs;
  final RxList<String> scientificNames = <String>[].obs;

  // Selected filters
  final RxString selectedCategory = ''.obs;
  final RxString selectedCompany = ''.obs;
  final RxString selectedScientificName = ''.obs;
  final Rx<RangeValues> priceRange = const RangeValues(0, 1000).obs;
  final RxString selectedSortOption = 'relevance'.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalResults = 0.obs;
  final RxInt resultsPerPage = 10.obs;

  // Search results
  final RxList<Medication> searchResults = <Medication>[].obs;

  // Sort options (for dropdown)
  final List<Map<String, String>> sortOptions = [
    {'value': 'relevance', 'label': 'الأكثر صلة'},
    {'value': 'price_asc', 'label': 'السعر: من الأقل إلى الأعلى'},
    {'value': 'price_desc', 'label': 'السعر: من الأعلى إلى الأقل'},
    {'value': 'name_asc', 'label': 'الاسم: أ-ي'},
    {'value': 'name_desc', 'label': 'الاسم: ي-أ'},
    {'value': 'visits_desc', 'label': 'الأكثر زيارة'},
    {'value': 'date_desc', 'label': 'الأحدث'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadFilterOptions();
    debounce(searchQuery, (_) => search(),
        time: const Duration(milliseconds: 500));

    // Check if search query was passed
    if (Get.arguments != null && Get.arguments['query'] != null) {
      searchTextController.text = Get.arguments['query'];
      searchQuery.value = Get.arguments['query'];
      search();
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void toggleAiSearch() {
    isAiSearch.toggle();
    if (searchQuery.isNotEmpty) {
      search();
    }
  }

  void toggleFilters() {
    showFilters.toggle();
  }

  void resetFilters() {
    selectedCategory.value = '';
    selectedCompany.value = '';
    selectedScientificName.value = '';
    priceRange.value = const RangeValues(0, 1000);
    selectedSortOption.value = 'relevance';
    if (searchQuery.isNotEmpty) {
      search();
    }
  }

  void applyFilters() {
    currentPage.value = 1;
    search();
  }

  Future<void> loadFilterOptions() async {
    try {
      // Load categories
      final categoriesResponse = await categoryRepository.getCategories();
      if (categoriesResponse != null) {
        categories.value = categoriesResponse.map((c) => c.arabicName).toList();
      }

      // Load companies
      final companiesResponse = await companyRepository.getCompanies();
      if (companiesResponse != null) {
        companies.value = companiesResponse;
      }

      // Load scientific names
      final scientificNamesResponse =
          await scientificNameRepository.getScientificNames();
      if (scientificNamesResponse != null) {
        scientificNames.value = scientificNamesResponse;
      }
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  Future<void> search() async {
    if (searchQuery.isEmpty &&
        selectedCategory.isEmpty &&
        selectedCompany.isEmpty &&
        selectedScientificName.isEmpty) {
      change(null, status: RxStatus.empty());
      searchResults.clear();
      return;
    }

    try {
      isLoading(true);
      change(null, status: RxStatus.loading());

      final SearchResponse? response;

      if (isAiSearch.value) {
        response = await medicationRepository.aiSearch(
          query: searchQuery.value,
          page: currentPage.value,
          limit: resultsPerPage.value,
        );
      } else {
        response = await medicationRepository.searchMedications(
          query: searchQuery.value,
          page: currentPage.value,
          limit: resultsPerPage.value,
          category: selectedCategory.value,
          company: selectedCompany.value,
          scientificName: selectedScientificName.value,
          priceMin: priceRange.value.start,
          priceMax: priceRange.value.end,
          sort: selectedSortOption.value,
        );
      }

      if (response != null) {
        searchResults.value = response.results;
        totalPages.value = response.pages;
        totalResults.value = response.total;
        change(response,
            status: response.results.isEmpty
                ? RxStatus.empty()
                : RxStatus.success());
      } else {
        change(null, status: RxStatus.error('حدث خطأ أثناء البحث'));
      }
    } catch (e) {
      print('Error searching medications: $e');
      change(null, status: RxStatus.error('حدث خطأ أثناء البحث'));
    } finally {
      isLoading(false);
    }
  }

  void goToPage(int page) {
    if (page > 0 && page <= totalPages.value) {
      currentPage.value = page;
      search();
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      search();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      search();
    }
  }
}
