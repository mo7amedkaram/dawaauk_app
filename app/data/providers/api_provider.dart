// lib/app/data/providers/api_provider.dart
import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';
import '../models/medication_model.dart';

class ApiProvider extends GetConnect {
  final String baseUrl = 'https://ilsinitiative.org/pharmacy/api';

  @override
  void onInit() {
    httpClient.baseUrl = baseUrl;
    httpClient.defaultDecoder = (map) => map;

    httpClient.addResponseModifier((request, response) {
      // Handle response errors globally
      return response;
    });
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.maxAuthRetries = 3;
    super.onInit();
  }

  // Search medications
  Future<Response> searchMedications({
    String? query,
    String method = 'trade_name',
    int page = 1,
    int limit = 12,
    String? category,
    String? company,
    String? scientificName,
    double? priceMin,
    double? priceMax,
    String sort = 'relevance',
  }) {
    final Map<String, dynamic> queryParams = {
      if (query != null && query.isNotEmpty) 'q': query,
      'method': method,
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null && category.isNotEmpty) 'category': category,
      if (company != null && company.isNotEmpty) 'company': company,
      if (scientificName != null && scientificName.isNotEmpty)
        'scientific_name': scientificName,
      if (priceMin != null) 'price_min': priceMin.toString(),
      if (priceMax != null) 'price_max': priceMax.toString(),
      'sort': sort,
    };

    return get('/medications/search', query: queryParams);
  }

  // AI Search (if enabled)
  Future<Response> aiSearch(
      {required String query, int page = 1, int limit = 12}) {
    return get('/medications/ai-search', query: {
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  // Chat Search (if enabled)
  Future<Response> chatSearch({
    required String query,
    List<Map<String, String>>? history,
    int page = 1,
    int limit = 12,
  }) {
    return get('/medications/chat-search', query: {
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
      if (history != null) 'history': history.toString(),
    });
  }

  // Get medication details
  Future<Response> getMedicationDetails(int id) {
    return get('/medications/$id');
  }

  // Compare medications
  Future<Response> compareMedications(List<int> ids) {
    final idsString = ids.join(',');
    return get('/medications/compare', query: {'ids': idsString});
  }

  // Get statistics
  Future<Response> getStatistics() {
    return get('/statistics');
  }

  // Get categories
  Future<Response> getCategories() {
    return get('/categories');
  }

  // Get category details
  Future<Response> getCategoryDetails(int id) {
    return get('/categories/$id');
  }

  // Get companies
  Future<Response> getCompanies() {
    return get('/companies');
  }

  // Get scientific names
  Future<Response> getScientificNames({int limit = 100}) {
    return get('/scientific-names', query: {'limit': limit.toString()});
  }
}
