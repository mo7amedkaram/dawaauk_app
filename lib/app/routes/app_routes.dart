// lib/app/routes/app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // Routes existantes
  static const HOME = _Paths.HOME;
  static const SEARCH = _Paths.SEARCH;
  static const DETAILS = _Paths.DETAILS;
  static const COMPARE = _Paths.COMPARE;
  static const CATEGORIES = _Paths.CATEGORIES;
  static const STATISTICS = _Paths.STATISTICS;
  static const CATEGORY_DETAILS = _Paths.CATEGORY_DETAILS;

  // Nouvelles routes
  static const SYNC = _Paths.SYNC;
  static const FAVORITES = _Paths.FAVORITES;
  static const PRESCRIPTIONS = _Paths.PRESCRIPTIONS;
  static const PRESCRIPTION_DETAILS = _Paths.PRESCRIPTION_DETAILS;
  static const PRESCRIPTION_EDIT = _Paths.PRESCRIPTION_EDIT;
  static const INVOICES = _Paths.INVOICES;
  static const INVOICE_DETAILS = _Paths.INVOICE_DETAILS;
  static const INVOICE_EDIT = _Paths.INVOICE_EDIT;
  static const INVOICE_REPORTS = _Paths.INVOICE_REPORTS;
  static const USER_GUIDE = _Paths.USER_GUIDE;
}

abstract class _Paths {
  // Chemins existants
  static const HOME = '/home';
  static const SEARCH = '/search';
  static const DETAILS = '/details/:id';
  static const COMPARE = '/compare';
  static const CATEGORIES = '/categories';
  static const STATISTICS = '/statistics';
  static const CATEGORY_DETAILS = '/categories/:id';

  // Nouveaux chemins
  static const SYNC = '/sync';
  static const FAVORITES = '/favorites';
  static const PRESCRIPTIONS = '/prescriptions';
  static const PRESCRIPTION_DETAILS = '/prescriptions/details/:id';
  static const PRESCRIPTION_EDIT = '/prescriptions/edit';
  static const INVOICES = '/invoices';
  static const INVOICE_DETAILS = '/invoices/details/:id';
  static const INVOICE_EDIT = '/invoices/edit';
  static const INVOICE_REPORTS = '/invoices/reports';
  static const USER_GUIDE = '/user-guide';
}
