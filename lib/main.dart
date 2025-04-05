// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد الحزمة

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // استيراد الحزمة

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for theme persistence
  await GetStorage.init();

  // Set preferred device orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    InitialBinding().dependencies();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // تصميم قياسي لـ iPhone X
      minTextAdapt: true, // تكييف النص حسب حجم الشاشة
      splitScreenMode: true, // دعم وضع الشاشة المنقسمة
      builder: (context, child) {
        return GetBuilder<ThemeController>(
          builder: (themeController) => GetMaterialApp(
            title: "دواؤك",
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.themeMode,
            locale: const Locale('ar', 'AE'),
            textDirection: TextDirection.rtl,
            defaultTransition: Transition.fade,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AE'),
            ],
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              // استخدام ScreenUtil لتطبيق الحجم المناسب على النصوص واتصالات الشبكة
              ScreenUtil.init(context);
              return MediaQuery(
                // التأكد من تطبيق حجم النص من إعدادات النظام
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget!,
              );
            },
          ),
        );
      },
    );
  }
}
