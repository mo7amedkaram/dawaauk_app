// lib/app/modules/search/controllers/enhanced_search_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/local/database_manager.dart';
import '../../../data/models/medication_model.dart';
import '../../../data/repositories/favorites_repository.dart';

class EnhancedSearchController extends GetxController
    with StateMixin<SearchResult> {
  final DatabaseManager _dbManager = Get.find<DatabaseManager>();
  final FavoritesRepository _favoritesRepository =
      Get.find<FavoritesRepository>();

  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool showFilters = false.obs;

  // Filtres
  final RxString selectedCategory = ''.obs;
  final RxString selectedCompany = ''.obs;
  final RxString selectedScientificName = ''.obs;
  final Rx<RangeValues> priceRange = const RangeValues(0, 1000).obs;
  final RxString selectedSortOption = 'relevance'.obs;

  // Options disponibles pour les filtres
  final RxList<String> categories = <String>[].obs;
  final RxList<String> companies = <String>[].obs;
  final RxList<String> scientificNames = <String>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalResults = 0.obs;
  final RxInt resultsPerPage = 20.obs;

  // Résultats de recherche
  final RxList<Medication> searchResults = <Medication>[].obs;
  final RxList<Medication> suggestedResults = <Medication>[].obs;

  // En tapant un mode de saisie (pour gérer les suggestions en temps réel)
  final RxBool isTyping = false.obs;
  final RxInt typingDelay = 300.obs; // Délai en millisecondes

  // Options de tri
  final List<Map<String, String>> sortOptions = [
    {'value': 'relevance', 'label': 'الأكثر صلة'},
    {'value': 'price_asc', 'label': 'السعر: من الأقل إلى الأعلى'},
    {'value': 'price_desc', 'label': 'السعر: من الأعلى إلى الأقل'},
    {'value': 'name_asc', 'label': 'الاسم: أ-ي'},
    {'value': 'name_desc', 'label': 'الاسم: ي-أ'},
    {'value': 'visits_desc', 'label': 'الأكثر زيارة'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadFilterOptions();

    // Gérer les recherches avec debounce pour éviter trop d'appels
    debounce(
      searchQuery,
      (_) {
        if (searchQuery.value.isEmpty) {
          suggestedResults.clear();
          isTyping.value = false;
          if (!showFilters.value) {
            change(null, status: RxStatus.empty());
          } else {
            search();
          }
        } else {
          isTyping.value = true;
          getSuggestions();
        }
      },
      time: Duration(milliseconds: typingDelay.value),
    );

    // Vérifier si des paramètres de recherche ont été passés
    if (Get.arguments != null) {
      if (Get.arguments['query'] != null) {
        searchTextController.text = Get.arguments['query'];
        searchQuery.value = Get.arguments['query'];
      }

      if (Get.arguments['category'] != null) {
        selectedCategory.value = Get.arguments['category'];
      }

      if (Get.arguments['company'] != null) {
        selectedCompany.value = Get.arguments['company'];
      }

      if (Get.arguments['sort'] != null) {
        selectedSortOption.value = Get.arguments['sort'];
      }

      // Effectuer la recherche si des paramètres ont été fournis
      if (Get.arguments.isNotEmpty) {
        search();
      }
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  // Mettre à jour la requête de recherche
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Afficher/masquer le panneau de filtres
  void toggleFilters() {
    showFilters.toggle();
    if (showFilters.value && categories.isEmpty) {
      loadFilterOptions();
    }
  }

  // Réinitialiser tous les filtres
  void resetFilters() {
    selectedCategory.value = '';
    selectedCompany.value = '';
    selectedScientificName.value = '';
    priceRange.value = const RangeValues(0, 1000);
    selectedSortOption.value = 'relevance';

    if (searchQuery.isNotEmpty || showFilters.value) {
      search();
    }
  }

  // Appliquer les filtres et effectuer la recherche
  void applyFilters() {
    currentPage.value = 1;
    search();
  }

  // Charger les options pour les filtres depuis la base de données locale
  Future<void> loadFilterOptions() async {
    try {
      // Charger les catégories
      final categoriesData = await _dbManager.getAllCategories();
      if (categoriesData.isNotEmpty) {
        categories.value = categoriesData.map((c) => c.arabicName).toList();
      }

      // Charger les entreprises (compagnies)
      final companiesResult = await _dbManager.database?.query(
        'medications',
        columns: ['DISTINCT company'],
        orderBy: 'company ASC',
      );

      if (companiesResult != null && companiesResult.isNotEmpty) {
        companies.value = companiesResult
            .map((row) => row['company'] as String)
            .where((name) => name.isNotEmpty)
            .toList();
      }

      // Charger les noms scientifiques
      final scientificNamesResult = await _dbManager.database?.query(
        'medications',
        columns: ['DISTINCT scientific_name'],
        orderBy: 'scientific_name ASC',
      );

      if (scientificNamesResult != null && scientificNamesResult.isNotEmpty) {
        scientificNames.value = scientificNamesResult
            .map((row) => row['scientific_name'] as String)
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Error loading filter options: $e');
    }
  }

  // Obtenir des suggestions pendant la saisie
  Future<void> getSuggestions() async {
    if (searchQuery.isEmpty) {
      suggestedResults.clear();
      return;
    }

    try {
      final results = await _dbManager.searchMedications(
        query: searchQuery.value,
        limit: 5,
      );

      suggestedResults.value = results;
    } catch (e) {
      print('Error getting suggestions: $e');
      suggestedResults.clear();
    }
  }

  // Effectuer la recherche complète
  Future<void> search() async {
    if (searchQuery.isEmpty && !showFilters.value) {
      change(null, status: RxStatus.empty());
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    isTyping.value = false;
    change(null, status: RxStatus.loading());

    try {
      final results = await _dbManager.searchMedications(
        query: searchQuery.value,
        category: selectedCategory.value,
        company: selectedCompany.value,
        scientificName: selectedScientificName.value,
        priceMin: priceRange.value.start,
        priceMax: priceRange.value.end,
        sort: selectedSortOption.value,
        page: currentPage.value,
        limit: resultsPerPage.value,
      );

      searchResults.value = results;

      // Si aucun résultat n'a été trouvé, essayer une recherche plus flexible
      if (results.isEmpty && searchQuery.isNotEmpty) {
        // Rechercher des médicaments similaires
        final similarResults = await _dbManager.getSimilarMedications(
          searchQuery.value,
          limit: 10,
        );

        if (similarResults.isNotEmpty) {
          // Créer un résultat de recherche avec des suggestions
          change(
            SearchResult(
              query: searchQuery.value,
              results: [],
              suggestions: similarResults,
              totalResults: 0,
              page: 1,
              totalPages: 1,
            ),
            status: RxStatus.success(),
          );
        } else {
          change(null, status: RxStatus.empty());
        }
      } else {
        // Obtenir le nombre total de résultats pour la pagination
        final countResult = await _dbManager.database?.rawQuery(
          '''
          SELECT COUNT(*) as count
          FROM medications
          WHERE trade_name LIKE ? OR scientific_name LIKE ?
          ''',
          ['%${searchQuery.value}%', '%${searchQuery.value}%'],
        );

        final totalCount = countResult != null && countResult.isNotEmpty
            ? Rx<int>(countResult.first['count'] as int)
            : Rx<int>(results.length);

        totalResults.value = totalCount.value;
        totalPages.value = (totalCount.value / resultsPerPage.value).ceil();

        // Créer un résultat de recherche standard
        change(
          SearchResult(
            query: searchQuery.value,
            results: results,
            suggestions: [],
            totalResults: totalCount.value,
            page: currentPage.value,
            totalPages: totalPages.value,
          ),
          status: results.isEmpty ? RxStatus.empty() : RxStatus.success(),
        );
      }
    } catch (e) {
      print('Error searching medications: $e');
      change(null, status: RxStatus.error('حدث خطأ أثناء البحث'));
    } finally {
      isLoading.value = false;
    }
  }

  // Aller à une page spécifique
  void goToPage(int page) {
    if (page > 0 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      search();
    }
  }

  // Aller à la page suivante
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      search();
    }
  }

  // Aller à la page précédente
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      search();
    }
  }

  // Ajouter ou supprimer un médicament des favoris
  Future<void> toggleFavorite(int medicationId) async {
    final isFav = await _favoritesRepository.isFavorite(medicationId);

    if (isFav) {
      await _favoritesRepository.removeFromFavorites(medicationId);
    } else {
      await _favoritesRepository.addToFavorites(medicationId);
    }
  }

  // Vérifier si un médicament est dans les favoris
  Future<bool> isFavorite(int medicationId) async {
    return await _favoritesRepository.isFavorite(medicationId);
  }
}

// Classe pour contenir les résultats de recherche avec d'éventuelles suggestions
class SearchResult {
  final String query;
  final List<Medication> results;
  final List<Medication> suggestions;
  final int totalResults;
  final int page;
  final int totalPages;

  SearchResult({
    required this.query,
    required this.results,
    required this.suggestions,
    required this.totalResults,
    required this.page,
    required this.totalPages,
  });
}
