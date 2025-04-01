// lib/app/modules/category_details/bindings/category_details_binding.dart
import 'package:get/get.dart';
import '../controllers/category_details_controller.dart';

class CategoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryDetailsController>(() => CategoryDetailsController());
  }
}
