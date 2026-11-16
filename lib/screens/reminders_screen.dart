import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Upgraded Flutter Reminders screen matching web app:
/// No strike-through text, active badges, in-app notification toasts, and custom reminder creation.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Reminder> _items = List.of(initialReminders);
  final _textCtrl = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 45);

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _showNotification(String title, String body) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.peachBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _toggle(int i) {
    setState(() {
      _items[i] = _items[i].toggled();
    });
    if (_items[i].done) {
      _showNotification('🔔 Reminder Scheduled & Active', _items[i].text);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _addReminder() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final timeStr = _selectedTime.format(context);
    setState(() {
      _items.insert(0, Reminder(text, timeStr, true));
      _textCtrl.clear();
    });
    _showNotification('⏰ Exact Reminder Set ($timeStr)', text);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Daily Care Reminders',
      eyebrow: 'DAILY CARE & ALERTS',
      activePath: Routes.dashboard,
      description: 'Scheduled reminders for hydration, iron supplements, and pregnancy checkups.',
      children: [
        // Notification Test Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.peachBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_active, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Push Notifications',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 15),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Get reminders for hydration and prenatal vitamins.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showNotification(
                  '💧 Drink Water Alert!',
                  'Time to drink 1 glass of water to stay hydrated and support circulation.',
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Test Alert'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Add Reminder Card
        ContentCard(
          kicker: 'SCHEDULE',
          title: 'Add New Care Reminder',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reminder details',
                  hintText: 'e.g. Drink 1 glass of water, Take Iron Tablet',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text('Time: ${_selectedTime.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add & Set'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Reminders List
        ContentCard(
          kicker: 'SCHEDULED TASKS',
          title: 'Your Care Schedule',
          child: Column(
            children: [
              for (var i = 0; i < _items.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _items[i].done ? AppColors.successBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _items[i].done ? AppColors.success : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _toggle(i),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            _items[i].done ? Icons.check_circle : Icons.circle_outlined,
                            color: _items[i].done ? AppColors.success : AppColors.muted,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clean bold text WITHOUT strike-through
                                Text(
                                  _items[i].text,
                                  style: TextStyle(
                                    fontWeight: _items[i].done ? FontWeight.w700 : FontWeight.w500,
                                    color: _items[i].done ? AppColors.ink : AppColors.inkSoft,
                                    fontSize: 14,
                                    decoration: null, // STRICTLY NO STRIKE-THROUGH
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _items[i].time,
                                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                    ),
                                    if (_items[i].done) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.successBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Active',
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, size: 20),
                            color: AppColors.primary,
                            tooltip: 'Notify Now',
                            onPressed: () => _showNotification('⏰ Scheduled Alert (${_items[i].time})', _items[i].text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
