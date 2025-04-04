import 'package:flutter/material.dart';

class PerformanceHelpers {
  // تقليل عدد إعادة البناء للواجهات في القوائم
  static Widget buildOptimizedList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    Widget? separatorBuilder,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (separatorBuilder != null && index > 0) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              separatorBuilder,
              itemBuilder(context, items[index]),
            ],
          );
        }
        return itemBuilder(context, items[index]);
      },
    );
  }

  // تحسين بناء الشبكات
  static Widget buildOptimizedGrid<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required SliverGridDelegate gridDelegate,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index]),
    );
  }

  // تخصيص حجم العناصر حسب حجم الشاشة
  static double getResponsiveSize(BuildContext context,
      {double small = 14, double medium = 16, double large = 18}) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) return small;
    if (width < 600) return medium;
    return large;
  }

  // تحديد عدد الأعمدة المناسب حسب عرض الشاشة
  static int getResponsiveGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }
}
