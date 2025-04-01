import 'package:get/get.dart';

class Medication {
  final int id;
  final String tradeName;
  final String scientificName;
  final String company;
  final double currentPrice;
  final double? oldPrice;
  final String category;
  final int? visitCount;
  final MedicationDetails? details;
  final Map<String, String>? links;

  Medication({
    required this.id,
    required this.tradeName,
    required this.scientificName,
    required this.company,
    required this.currentPrice,
    this.oldPrice,
    required this.category,
    this.visitCount,
    this.details,
    this.links,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      tradeName: json['trade_name'],
      scientificName: json['scientific_name'],
      company: json['company'],
      currentPrice: json['current_price'].toDouble(),
      oldPrice: json['old_price'] != null ? json['old_price'].toDouble() : null,
      category: json['category'],
      visitCount: json['visit_count'],
      details: json['details'] != null
          ? MedicationDetails.fromJson(json['details'])
          : null,
      links: json['links'] != null
          ? Map<String, String>.from(json['links'])
          : null,
    );
  }
}

class MedicationDetails {
  final String? indications;
  final String? dosage;
  final String? sideEffects;
  final String? contraindications;
  final String? interactions;
  final String? storageInfo;
  final String? usageInstructions;

  MedicationDetails({
    this.indications,
    this.dosage,
    this.sideEffects,
    this.contraindications,
    this.interactions,
    this.storageInfo,
    this.usageInstructions,
  });

  factory MedicationDetails.fromJson(Map<String, dynamic> json) {
    return MedicationDetails(
      indications: json['indications'],
      dosage: json['dosage'],
      sideEffects: json['side_effects'],
      contraindications: json['contraindications'],
      interactions: json['interactions'],
      storageInfo: json['storage_info'],
      usageInstructions: json['usage_instructions'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final String arabicName;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabic_name'],
      description: json['description'],
    );
  }
}

class SearchResponse {
  final List<Medication> results;
  final int total;
  final int page;
  final int limit;
  final int pages;
  final String? query;
  final Map<String, dynamic>? filters;
  final bool success;

  SearchResponse({
    required this.results,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    this.query,
    this.filters,
    required this.success,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      results:
          (json['results'] as List).map((e) => Medication.fromJson(e)).toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      pages: json['pages'],
      query: json['query'],
      filters: json['filters'],
      success: json['success'] ?? true,
    );
  }
}

class MedicationDetailResponse {
  final Medication medication;
  final List<Medication> equivalentMedications;
  final List<Medication> alternatives;
  final List<Medication> therapeuticAlternatives;

  MedicationDetailResponse({
    required this.medication,
    required this.equivalentMedications,
    required this.alternatives,
    required this.therapeuticAlternatives,
  });

  factory MedicationDetailResponse.fromJson(Map<String, dynamic> json) {
    return MedicationDetailResponse(
      medication: Medication.fromJson(json['medication']),
      equivalentMedications: json['equivalent_medications'] != null
          ? (json['equivalent_medications'] as List)
              .map((e) => Medication.fromJson(e))
              .toList()
          : [],
      alternatives: json['alternatives'] != null
          ? (json['alternatives'] as List)
              .map((e) => Medication.fromJson(e))
              .toList()
          : [],
      therapeuticAlternatives: json['therapeutic_alternatives'] != null
          ? (json['therapeutic_alternatives'] as List)
              .map((e) => Medication.fromJson(e))
              .toList()
          : [],
    );
  }
}

class StatisticsResponse {
  final List<Medication> mostVisited;
  final List<Medication> mostSearched;
  final List<SearchTerm> topSearchTerms;
  final GeneralStats generalStats;

  StatisticsResponse({
    required this.mostVisited,
    required this.mostSearched,
    required this.topSearchTerms,
    required this.generalStats,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      mostVisited: (json['most_visited'] as List)
          .map((e) => Medication.fromJson(e))
          .toList(),
      mostSearched: (json['most_searched'] as List)
          .map((e) => Medication.fromJson(e))
          .toList(),
      topSearchTerms: (json['top_search_terms'] as List)
          .map((e) => SearchTerm.fromJson(e))
          .toList(),
      generalStats: GeneralStats.fromJson(json['general_stats']),
    );
  }
}

class SearchTerm {
  final String searchTerm;
  final int searchCount;
  final String lastSearchDate;

  SearchTerm({
    required this.searchTerm,
    required this.searchCount,
    required this.lastSearchDate,
  });

  factory SearchTerm.fromJson(Map<String, dynamic> json) {
    return SearchTerm(
      searchTerm: json['search_term'],
      searchCount: json['search_count'],
      lastSearchDate: json['last_search_date'],
    );
  }
}

class GeneralStats {
  final int totalMedications;
  final int totalVisits;
  final int totalSearches;
  final double averagePrice;

  GeneralStats({
    required this.totalMedications,
    required this.totalVisits,
    required this.totalSearches,
    required this.averagePrice,
  });

  factory GeneralStats.fromJson(Map<String, dynamic> json) {
    return GeneralStats(
      totalMedications: json['total_medications'],
      totalVisits: json['total_visits'],
      totalSearches: json['total_searches'],
      averagePrice: json['average_price'].toDouble(),
    );
  }
}
