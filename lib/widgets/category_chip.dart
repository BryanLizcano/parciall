import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;

  const CategoryChip({super.key, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
