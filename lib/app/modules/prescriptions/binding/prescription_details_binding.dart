// lib/app/modules/prescription_details/bindings/prescription_details_binding.dart
import 'package:get/get.dart';
import '../controller/prescription_details_controller.dart';

class PrescriptionDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrescriptionDetailsController>(
      () => PrescriptionDetailsController(),
    );
  }
}
