// lib/app/routes/app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const SEARCH = _Paths.SEARCH;
  static const DETAILS = _Paths.DETAILS;
  static const COMPARE = _Paths.COMPARE;
  static const CATEGORIES = _Paths.CATEGORIES;
  static const STATISTICS = _Paths.STATISTICS;
  static const CATEGORY_DETAILS = _Paths.CATEGORY_DETAILS;
}

abstract class _Paths {
  static const HOME = '/home';
  static const SEARCH = '/search';
  static const DETAILS = '/details/:id';
  static const COMPARE = '/compare';
  static const CATEGORIES = '/categories';
  static const STATISTICS = '/statistics';
  static const CATEGORY_DETAILS = '/categories/:id';
}
