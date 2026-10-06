import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Web `.content-card` with optional `.card-kicker` and heading.
class ContentCard extends StatelessWidget {
  const ContentCard({super.key, this.kicker, this.title, required this.child, this.padding = const EdgeInsets.all(20)});
  final String? kicker;
  final String? title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null)
                Text(kicker!, style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
              if (title != null) ...[
                const SizedBox(height: 4),
                Text(title!, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      );
}

/// Web `.list-row`: title + subtitle on the left, trailing widget (status pill) on the right.
class ListRow extends StatelessWidget {
  const ListRow({super.key, required this.title, this.subtitle, this.trailing, this.onTap});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: AppColors.muted)),
        trailing: trailing,
        onTap: onTap,
      );
}

/// Small rounded status pill.
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.color = AppColors.success, this.background = AppColors.successBg});
  final String label;
  final Color color, background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      );
}
