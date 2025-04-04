// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../data/providers/api_provider.dart';
import '../data/repositories/medication_repository.dart';

import '../theme/theme_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // API Provider
    Get.put<ApiProvider>(ApiProvider(), permanent: true);

    // Repositories
    Get.put<MedicationRepository>(MedicationRepository(), permanent: true);
    Get.put<CategoryRepository>(CategoryRepository(), permanent: true);
    Get.put<StatisticsRepository>(StatisticsRepository(), permanent: true);
    Get.put<CompanyRepository>(CompanyRepository(), permanent: true);
    Get.put<ScientificNameRepository>(ScientificNameRepository(),
        permanent: true);

    // Theme Controller
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}
