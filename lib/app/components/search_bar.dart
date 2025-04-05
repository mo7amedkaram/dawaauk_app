// lib/app/components/search_bar.dart
import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autoFocus;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;
  final bool showAiButton;
  final bool isAiEnabled;
  final VoidCallback? onAiToggle;

  const AppSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'ابحث عن دواء...',
    this.autoFocus = false,
    this.showFilterButton = true,
    this.onFilterTap,
    this.showAiButton = false,
    this.isAiEnabled = false,
    this.onAiToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filter button
          if (showFilterButton && onFilterTap != null)
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Icons.tune),
              tooltip: 'الفلاتر',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 24,
            ),

          if (showFilterButton && onFilterTap != null) const SizedBox(width: 8),

          // Search field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autoFocus,
              textAlignVertical: TextAlignVertical.center,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                          if (onClear != null) onClear!();
                          onChanged('');
                        },
                        icon: const Icon(Icons.clear),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                      )
                    : null,
              ),
            ),
          ),

          // AI button
          if (showAiButton && onAiToggle != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAiToggle,
              icon: Icon(
                isAiEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                color: isAiEnabled ? theme.colorScheme.primary : null,
              ),
              tooltip: isAiEnabled ? 'تعطيل البحث الذكي' : 'تفعيل البحث الذكي',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 24,
            ),
          ],
        ],
      ),
    );
  }
}
