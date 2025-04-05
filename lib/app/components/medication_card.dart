// lib/app/components/medication_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/models/medication_model.dart';
import '../utils/text_utils.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final bool showActions;
  final bool isSelected;
  final VoidCallback? onSelect;

  const MedicationCard({
    Key? key,
    required this.medication,
    this.showActions = true,
    this.isSelected = false,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = medication.oldPrice != null &&
        medication.oldPrice! > medication.currentPrice;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2.r)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/details/${medication.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with category
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.h),
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: AppTextUtils.smallText(
                medication.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trade name
                  AppTextUtils.mediumTitle(
                    medication.tradeName,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Scientific name
                  AppTextUtils.smallText(
                    medication.scientificName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Company
                  Row(
                    children: [
                      Icon(Icons.business,
                          size: 16.sp, color: theme.colorScheme.secondary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: AppTextUtils.smallText(
                          medication.company,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Current price
                      Text(
                        medication.currentPrice.toStringAsFixed(2),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'ج.م',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 12.sp,
                        ),
                      ),

                      // Show old price if there's a discount
                      if (hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Text(
                          medication.oldPrice!.toStringAsFixed(2),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.error,
                            fontSize: 12.sp,
                          ),
                        ),

                        // Discount percentage
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '-${(((medication.oldPrice! - medication.currentPrice) / medication.oldPrice!) * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            if (showActions)
              Padding(
                padding: EdgeInsets.fromLTRB(12.r, 0, 12.r, 12.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Details button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Get.toNamed('/details/${medication.id}'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.r),
                        ),
                        child: Text(
                          'التفاصيل',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Compare toggle
                    if (onSelect != null)
                      IconButton(
                        onPressed: onSelect,
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: isSelected ? theme.colorScheme.primary : null,
                          size: 24.sp,
                        ),
                        tooltip:
                            isSelected ? 'إزالة من المقارنة' : 'إضافة للمقارنة',
                        constraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
