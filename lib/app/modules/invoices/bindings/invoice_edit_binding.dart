// lib/app/modules/invoice_edit/bindings/invoice_edit_binding.dart
import 'package:get/get.dart';

import '../controller/invoice_edit_controller.dart';

class InvoiceEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceEditController>(() => InvoiceEditController());
  }
}
