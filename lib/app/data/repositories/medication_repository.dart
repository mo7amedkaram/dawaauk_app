// lib/app/data/repositories/medication_repository.dart
import 'package:get/get.dart';
import '../models/medication_model.dart';
import '../providers/api_provider.dart';

class MedicationRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<SearchResponse?> searchMedications({
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
  }) async {
    try {
      final response = await _apiProvider.searchMedications(
        query: query,
        method: method,
        page: page,
        limit: limit,
        category: category,
        company: company,
        scientificName: scientificName,
        priceMin: priceMin,
        priceMax: priceMax,
        sort: sort,
      );

      if (response.status.hasError) {
        return null;
      }

      return SearchResponse.fromJson(response.body);
    } catch (e) {
      print('Error searching medications: $e');
      return null;
    }
  }

  Future<MedicationDetailResponse?> getMedicationDetails(int id) async {
    try {
      final response = await _apiProvider.getMedicationDetails(id);

      if (response.status.hasError) {
        return null;
      }

      return MedicationDetailResponse.fromJson(response.body);
    } catch (e) {
      print('Error getting medication details: $e');
      return null;
    }
  }

  Future<List<Medication>?> compareMedications(List<int> ids) async {
    try {
      final response = await _apiProvider.compareMedications(ids);

      if (response.status.hasError) {
        return null;
      }

      final medications = (response.body['medications'] as List)
          .map((e) => Medication.fromJson(e))
          .toList();

      return medications;
    } catch (e) {
      print('Error comparing medications: $e');
      return null;
    }
  }

  Future<SearchResponse?> aiSearch(
      {required String query, int page = 1, int limit = 12}) async {
    try {
      final response = await _apiProvider.aiSearch(
        query: query,
        page: page,
        limit: limit,
      );

      if (response.status.hasError) {
        return null;
      }

      return SearchResponse.fromJson(response.body);
    } catch (e) {
      print('Error AI searching medications: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> chatSearch({
    required String query,
    List<Map<String, String>>? history,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _apiProvider.chatSearch(
        query: query,
        history: history,
        page: page,
        limit: limit,
      );

      if (response.status.hasError) {
        return null;
      }

      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('Error chat searching medications: $e');
      return null;
    }
  }
}

// lib/app/data/repositories/category_repository.dart
class CategoryRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<List<Category>?> getCategories() async {
    try {
      final response = await _apiProvider.getCategories();

      if (response.status.hasError) {
        return null;
      }

      final categories = (response.body['categories'] as List)
          .map((e) => Category.fromJson(e))
          .toList();

      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCategoryDetails(int id) async {
    try {
      final response = await _apiProvider.getCategoryDetails(id);

      if (response.status.hasError) {
        return null;
      }

      return response.body as Map<String, dynamic>;
    } catch (e) {
      print('Error getting category details: $e');
      return null;
    }
  }
}

// lib/app/data/repositories/statistics_repository.dart
class StatisticsRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<StatisticsResponse?> getStatistics() async {
    try {
      final response = await _apiProvider.getStatistics();

      if (response.status.hasError) {
        return null;
      }

      return StatisticsResponse.fromJson(response.body);
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }
}

// lib/app/data/repositories/company_repository.dart
class CompanyRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<List<String>?> getCompanies() async {
    try {
      final response = await _apiProvider.getCompanies();

      if (response.status.hasError) {
        return null;
      }

      final companies = (response.body['companies'] as List)
          .map((e) => e['company'] as String)
          .toList();

      return companies;
    } catch (e) {
      print('Error getting companies: $e');
      return null;
    }
  }
}

// lib/app/data/repositories/scientific_name_repository.dart
class ScientificNameRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  Future<List<String>?> getScientificNames({int limit = 100}) async {
    try {
      final response = await _apiProvider.getScientificNames(limit: limit);

      if (response.status.hasError) {
        return null;
      }

      final scientificNames = (response.body['scientific_names'] as List)
          .map((e) => e['scientific_name'] as String)
          .toList();

      return scientificNames;
    } catch (e) {
      print('Error getting scientific names: $e');
      return null;
    }
  }
}
