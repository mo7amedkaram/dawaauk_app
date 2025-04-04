// lib/app/modules/statistics/bindings/statistics_binding.dart
import 'package:get/get.dart';
import '../controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsController>(() => StatisticsController());
  }
}
