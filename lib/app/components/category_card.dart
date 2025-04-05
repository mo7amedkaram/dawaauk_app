// lib/app/components/category_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/models/medication_model.dart';
import '../utils/text_utils.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/categories/${category.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category color header

            // Content
            Padding(
              padding: EdgeInsets.all(16.r), // هوامش متجاوبة
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name - استخدام AppTextUtils لعنوان متجاوب
                  AppTextUtils.mediumTitle(
                    category.arabicName,
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h), // مسافة متجاوبة

                  // Category description - استخدام AppTextUtils لنص متجاوب
                  AppTextUtils.expandableText(
                    category.description,
                    style: theme.textTheme.bodyMedium,
                    minLines: 2,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const Spacer(), // للحفاظ على موضع الزر في الأسفل

            // Button
            Padding(
              padding:
                  EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r), // هوامش متجاوبة
              child: SizedBox(
                height: 36.h, // ارتفاع متجاوب
                child: OutlinedButton(
                  onPressed: () => Get.toNamed('/categories/${category.id}'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.r), // هوامش متجاوبة
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.r), // نصف قطر متجاوب
                    ),
                  ),
                  child: Text(
                    'عرض الأدوية',
                    style: TextStyle(
                      fontSize: 14.sp, // حجم خط متجاوب
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
