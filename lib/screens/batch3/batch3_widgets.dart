import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// `.action-row`: buttons that wrap on narrow screens.
class ActionRow extends StatelessWidget {
  const ActionRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 12, runSpacing: 12, children: children);
}

/// `.stat-card`: big number with a label.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ]),
      );
}

/// `.search-input`.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, required this.onChanged, this.icon = false});
  final String hint;
  final ValueChanged<String> onChanged;
  final bool icon;

  @override
  Widget build(BuildContext context) => TextField(
        onChanged: onChanged,
        decoration: InputDecoration(hintText: hint, prefixIcon: icon ? const Icon(Icons.search) : null),
      );
}
