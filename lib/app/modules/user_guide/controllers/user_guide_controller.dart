// lib/app/modules/user_guide/controllers/user_guide_controller.dart
import 'package:get/get.dart';

class UserGuideController extends GetxController {
  final RxInt currentPage = 0.obs;

  // Liste des sections du guide
  final List<GuideSection> sections = [
    GuideSection(
      title: 'مرحبا بك في تطبيق قاعدة بيانات الأدوية',
      description:
          'دليل المستخدم الشامل لكيفية استخدام التطبيق والاستفادة من جميع ميزاته',
      icon: 'assets/icons/welcome.png',
    ),
    GuideSection(
      title: 'البحث عن الأدوية',
      description:
          'استخدم شريط البحث للعثور على الأدوية بالاسم التجاري، المادة الفعالة، أو الشركة المنتجة. '
          'يمكنك استخدام الفلاتر لتضييق نطاق البحث حسب السعر، التصنيف، أو الشركة المصنعة.',
      icon: 'assets/icons/search.png',
      steps: [
        'اضغط على أيقونة البحث في الشاشة الرئيسية',
        'اكتب اسم الدواء أو جزء منه (النظام يدعم البحث المرن حتى لو نسيت حرف أو أخطأت في الكتابة)',
        'استخدم الفلاتر لتحسين نتائج البحث من خلال النقر على أيقونة الفلتر',
        'اضغط على أي دواء للاطلاع على تفاصيله الكاملة'
      ],
    ),
    GuideSection(
      title: 'عرض تفاصيل الدواء',
      description:
          'احصل على معلومات شاملة عن الدواء بما في ذلك الاسم العلمي، الشركة المصنعة، '
          'دواعي الاستعمال، الجرعة، الآثار الجانبية، والسعر.',
      icon: 'assets/icons/details.png',
      steps: [
        'اختر الدواء من نتائج البحث أو من الشاشة الرئيسية',
        'تصفح المعلومات المختلفة على شكل تبويبات: التفاصيل، البدائل المكافئة، البدائل، وغيرها',
        'استخدم زر "إضافة للمفضلة" لحفظ الدواء ضمن قائمة المفضلة',
        'استخدم زر "المقارنة" لمقارنة الدواء مع أدوية أخرى'
      ],
    ),
    GuideSection(
      title: 'المفضلة',
      description:
          'احفظ الأدوية التي تستخدمها بشكل متكرر أو تريد تذكرها في قائمة المفضلة للوصول السريع إليها.',
      icon: 'assets/icons/favorites.png',
      steps: [
        'اضغط على أيقونة القلب في صفحة تفاصيل الدواء لإضافته للمفضلة',
        'اضغط على "المفضلة" في القائمة السفلية للوصول إلى قائمة المفضلة',
        'يمكنك إزالة دواء من المفضلة عن طريق الضغط مرة أخرى على أيقونة القلب'
      ],
    ),
    GuideSection(
      title: 'الوصفات الطبية',
      description:
          'إنشاء وإدارة الوصفات الطبية للمرضى مع إمكانية تحويلها إلى فواتير.',
      icon: 'assets/icons/prescription.png',
      steps: [
        'انتقل إلى قسم "الوصفات الطبية" من القائمة الرئيسية',
        'اضغط على زر "+" لإنشاء وصفة طبية جديدة',
        'أدخل اسم المريض وعنوان الوصفة',
        'أضف الأدوية والجرعات والتعليمات',
        'يمكنك تحويل الوصفة إلى فاتورة بالضغط على "تحويل إلى فاتورة"'
      ],
    ),
    GuideSection(
      title: 'الفواتير والتقارير',
      description:
          'إنشاء وإدارة الفواتير ومتابعة المبيعات من خلال التقارير الإحصائية.',
      icon: 'assets/icons/invoice.png',
      steps: [
        'انتقل إلى قسم "الفواتير" من القائمة الرئيسية',
        'أنشئ فاتورة جديدة أو راجع الفواتير السابقة',
        'استخدم قسم "التقارير" للاطلاع على إحصائيات المبيعات',
        'يمكنك تصدير الفواتير أو طباعتها',
        'تابع أكثر الأدوية مبيعاً من خلال الرسوم البيانية'
      ],
    ),
    GuideSection(
      title: 'تزامن وتحديث قاعدة البيانات',
      description:
          'تحميل قاعدة البيانات الكاملة وتحديث معلومات الأدوية وأسعارها.',
      icon: 'assets/icons/sync.png',
      steps: [
        'في أول استخدام للتطبيق، سيتم تحميل قاعدة البيانات تلقائياً',
        'لتحديث قاعدة البيانات، انتقل إلى "الإعدادات" ثم "تحديث قاعدة البيانات"',
        'يمكنك الاطلاع على تاريخ آخر تحديث',
        'يفضل تحديث قاعدة البيانات بشكل دوري للحصول على أحدث الأسعار والأدوية'
      ],
    ),
    GuideSection(
      title: 'مقارنة الأدوية',
      description:
          'قارن بين الأدوية المختلفة من حيث السعر، المكونات، الآثار الجانبية وغيرها.',
      icon: 'assets/icons/compare.png',
      steps: [
        'يمكنك اختيار أكثر من دواء للمقارنة من خلال تفعيل وضع المقارنة',
        'حدد الأدوية التي تريد مقارنتها (يمكنك اختيار حتى 4 أدوية)',
        'اضغط على زر "مقارنة" للاطلاع على جدول مقارنة شامل',
        'يمكنك اختيار عناصر المقارنة التي تهمك (السعر، الآثار الجانبية، الجرعات، إلخ)'
      ],
    ),
  ];

  // Méthodes de navigation
  void nextPage() {
    if (currentPage.value < sections.length - 1) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < sections.length) {
      currentPage.value = page;
    }
  }

  // Vérifier si c'est la première page
  bool get isFirstPage => currentPage.value == 0;

  // Vérifier si c'est la dernière page
  bool get isLastPage => currentPage.value == sections.length - 1;

  // Obtenir la section actuelle
  GuideSection get currentSection => sections[currentPage.value];
}

class GuideSection {
  final String title;
  final String description;
  final String icon;
  final List<String>? steps;
  final String? imagePath;

  GuideSection({
    required this.title,
    required this.description,
    required this.icon,
    this.steps,
    this.imagePath,
  });
}
