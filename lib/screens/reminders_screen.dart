import 'package:flutter/material.dart';

import '../core/localization.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import 'batch4/content.dart';

/// Fully localized Reminders screen.
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

  String _getLocalizedTaskText(String raw, String Function(String) L) {
    final lower = raw.toLowerCase();
    if (lower.contains('iron supplement')) return L('rem_take_iron');
    if (lower.contains('glass of water') || lower.contains('water')) return L('rem_drink_water');
    if (lower.contains('doctor') || lower.contains('consultation')) return L('rem_doctor_consult');
    return raw;
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
              decoration: BoxDecoration(color: AppColors.peachBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_active, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(body, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
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
    setState(() { _items[i] = _items[i].toggled(); });
    if (_items[i].done) {
      _showNotification('🔔 ${LocalizationService.tr('reminder_scheduled')}', _items[i].text);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _addReminder() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final timeStr = _selectedTime.format(context);
    setState(() {
      _items.insert(0, Reminder(text, timeStr, true));
      _textCtrl.clear();
    });
    _showNotification('⏰ ${LocalizationService.tr('reminder_set')} ($timeStr)', text);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;
        return PageLayout(
          title: L('daily_care_reminders'),
          eyebrow: L('daily_care_eyebrow'),
          activePath: Routes.dashboard,
          description: L('reminders_desc'),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.notifications_active, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(L('live_notifications'), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 14)),
                        Text(L('notifications_desc'), style: const TextStyle(color: AppColors.inkSoft, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showNotification('💊 ${L('reminder_test_title')}', L('reminder_test_body')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(L('test_alert'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // Add New Reminder
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L('add_new_reminder'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textCtrl,
                    decoration: InputDecoration(
                      hintText: L('reminder_placeholder'),
                      filled: true,
                      fillColor: AppColors.peachBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text('${L('time')}: ${_selectedTime.format(context)}'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addReminder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(L('add_and_set')),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reminders List
            ContentCard(
              kicker: L('scheduled_tasks'),
              title: L('your_care_schedule'),
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
                                    Text(
                                      _getLocalizedTaskText(_items[i].text, L),
                                      style: TextStyle(
                                        fontWeight: _items[i].done ? FontWeight.w700 : FontWeight.w500,
                                        color: _items[i].done ? AppColors.ink : AppColors.inkSoft,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _items[i].time.toLowerCase().contains('tomorrow')
                                              ? L('tomorrow')
                                              : _items[i].time,
                                          style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                        ),
                                        if (_items[i].done) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(4)),
                                            child: Text(
                                              L('active'),
                                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11),
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
                                tooltip: L('notify_now'),
                                onPressed: () => _showNotification('⏰ ${L('scheduled_alert')} (${_items[i].time})', _items[i].text),
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
      },
    );
  }
}
