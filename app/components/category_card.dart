// lib/app/components/category_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/medication_model.dart';

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
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/categories/${category.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category color header
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.8),
                image: DecorationImage(
                  image: AssetImage('assets/images/category_bg.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary.withOpacity(0.8),
                    BlendMode.multiply,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.medication,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name
                  Text(
                    category.arabicName,
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Category description
                  Text(
                    category.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton(
                onPressed: () => Get.toNamed('/categories/${category.id}'),
                child: Text('عرض الأدوية'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
