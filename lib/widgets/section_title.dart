import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;

  const SectionTitle({super.key, required this.title, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (actionLabel != null) Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
