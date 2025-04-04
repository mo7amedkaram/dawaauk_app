// lib/app/routes/app_pages.dart
import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
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

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => SearchView(),
      binding: SearchBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.DETAILS,
      page: () => DetailsView(),
      binding: DetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.COMPARE,
      page: () => CompareView(),
      binding: CompareBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.CATEGORIES,
      page: () => CategoriesView(),
      binding: CategoriesBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.STATISTICS,
      page: () => StatisticsView(),
      binding: StatisticsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.CATEGORY_DETAILS,
      page: () => CategoryDetailsView(),
      binding: CategoryDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 200),
    ),
  ];
}
