// lib/app/modules/invoice_details/bindings/invoice_details_binding.dart
import 'package:get/get.dart';

import '../controller/invoice_details_controller.dart';

class InvoiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceDetailsController>(() => InvoiceDetailsController());
  }
}
