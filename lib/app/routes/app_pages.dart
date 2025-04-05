// lib/app/routes/app_pages.dart
import 'package:get/get.dart';

import '../modules/favorites/binding/favourite_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/invoices/bindings/invoice_binidng.dart';
import '../modules/invoices/bindings/invoice_details_binding.dart';
import '../modules/invoices/bindings/invoice_edit_binding.dart';
import '../modules/invoices/views/invoice_details_view.dart';
import '../modules/invoices/views/invoice_edit_view.dart';
import '../modules/prescriptions/binding/prescription_binding.dart';
import '../modules/prescriptions/binding/prescription_details_binding.dart';
import '../modules/prescriptions/views/prescription_details_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/details/bindings/details_binding.dart';
import '../modules/details/views/details_view.dart';
import '../modules/compare/bindings/compare_binding.dart';
import '../modules/compare/views/compare_view.dart';
import '../modules/categories/bindings/categories_binding.dart';
import '../modules/categories/views/categories_view.dart';
import '../modules/statistics/bindings/statistics_binding.dart';
import '../modules/statistics/views/statistics_view.dart';
import '../modules/category_details/bindings/category_details_binding.dart';
import '../modules/category_details/views/category_details_view.dart';

// Nouvelles importations
import '../modules/sync/binding/sync_binding.dart';
import '../modules/sync/views/sync_view.dart';
import '../modules/favorites/views/favorites_view.dart';
import '../modules/prescriptions/views/prescriptions_view.dart';

import '../modules/invoices/views/invoices_view.dart';

import '../modules/invoices/views/sales_reports_view.dart';
import '../modules/user_guide/binding/user_guide_binding.dart';
import '../modules/user_guide/views/user_guide_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    // Routes existantes
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.DETAILS,
      page: () => const DetailsView(),
      binding: DetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.COMPARE,
      page: () => const CompareView(),
      binding: CompareBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.STATISTICS,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.CATEGORY_DETAILS,
      page: () => const CategoryDetailsView(),
      binding: CategoryDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Nouvelles routes

    // Synchronisation
    GetPage(
      name: _Paths.SYNC,
      page: () => const SyncView(),
      binding: SyncBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Favoris
    GetPage(
      name: _Paths.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Ordonnances
    GetPage(
      name: _Paths.PRESCRIPTIONS,
      page: () => const PrescriptionsView(),
      binding: PrescriptionsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.PRESCRIPTION_DETAILS,
      page: () => const PrescriptionDetailsView(),
      binding: PrescriptionDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    /*

GetPage(
      name: _Paths.PRESCRIPTION_EDIT,
      page: () => PrescriptionEditView(),
      binding: PrescriptionEditBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
    */

    // Factures
    GetPage(
      name: _Paths.INVOICES,
      page: () => const InvoicesView(),
      binding: InvoiceBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.INVOICE_DETAILS,
      page: () => const InvoiceDetailsView(),
      binding: InvoiceDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.INVOICE_EDIT,
      page: () => const InvoiceEditView(),
      binding: InvoiceEditBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    /*
  GetPage(
      name: _Paths.INVOICE_REPORTS,
      page: () => SalesReportsView(),
      binding: InvoicesBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
  */

    // Guide d'utilisation
    GetPage(
      name: _Paths.USER_GUIDE,
      page: () => const UserGuideView(),
      binding: UserGuideBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
  ];
}
