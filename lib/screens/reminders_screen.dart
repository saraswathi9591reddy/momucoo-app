import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Port of frontend/src/pages/Reminders.jsx (route /reminders). In-memory only, as on web.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _items = List.of(initialReminders);

  void _toggle(int i) => setState(() => _items = [for (var j = 0; j < _items.length; j++) j == i ? _items[j].toggled() : _items[j]]);

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Reminders',
      eyebrow: 'DAILY CARE',
      activePath: Routes.dashboard,
      description: 'Small reminders to keep your care plan moving.',
      children: [
        ContentCard(
          child: Column(children: [
            for (var i = 0; i < _items.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _toggle(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(children: [
                    Text(_items[i].done ? '✓' : '○', style: TextStyle(fontSize: 20, color: _items[i].done ? AppColors.success : AppColors.muted)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_items[i].text,
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, decoration: _items[i].done ? TextDecoration.lineThrough : null)),
                        Text(_items[i].time, style: const TextStyle(color: AppColors.muted)),
                      ]),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
      ],
    );
  }
}
