// lib/app/components/medication_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/medication_model.dart';
import '../routes/app_pages.dart';

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
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/details/${medication.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with category
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trade name
                  Text(
                    medication.tradeName,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Scientific name
                  Text(
                    medication.scientificName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Company
                  Row(
                    children: [
                      Icon(Icons.business,
                          size: 16, color: theme.colorScheme.secondary),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          medication.company,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Current price
                      Text(
                        '${medication.currentPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'د.ك',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      // Show old price if there's a discount
                      if (hasDiscount) ...[
                        SizedBox(width: 8),
                        Text(
                          '${medication.oldPrice!.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.error,
                          ),
                        ),

                        // Discount percentage
                        Spacer(),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '-${(((medication.oldPrice! - medication.currentPrice) / medication.oldPrice!) * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else
                        Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            if (showActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Details button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Get.toNamed('/details/${medication.id}'),
                        child: Text('التفاصيل'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Compare toggle
                    if (onSelect != null)
                      IconButton(
                        onPressed: onSelect,
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        tooltip:
                            isSelected ? 'إزالة من المقارنة' : 'إضافة للمقارنة',
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
