import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/PatientProfile.jsx (route /profile).
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late Profile _profile;
  final Map<String, TextEditingController> _ctrl = {};
  bool _editing = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final s = AppStorage.instance;
    final stored = s.profile;
    if (stored != null) {
      _profile = stored;
    } else {
      final week = s.readMap(StorageKeys.pregnancyData)?['week'];
      _profile = Profile(
        name: 'Ananya Sharma',
        age: '21 Years',
        gender: 'Female',
        bloodGroup: 'O+',
        pregnancyStatus: 'Pregnant',
        pregnancyWeek: jsTruthy(week) ? '$week' : '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _get(String k) => switch (k) {
        'name' => _profile.name,
        'age' => _profile.age,
        'gender' => _profile.gender,
        'bloodGroup' => _profile.bloodGroup,
        'pregnancyStatus' => _profile.pregnancyStatus,
        'pregnancyWeek' => _profile.pregnancyWeek,
        _ => _profile.dueDate,
      };

  void _set(String k, String v) {
    setState(() {
      switch (k) {
        case 'name':
          _profile.name = v;
        case 'age':
          _profile.age = v;
        case 'gender':
          _profile.gender = v;
        case 'bloodGroup':
          _profile.bloodGroup = v;
        case 'pregnancyStatus':
          _profile.pregnancyStatus = v;
        case 'pregnancyWeek':
          _profile.pregnancyWeek = v;
        default:
          _profile.dueDate = v;
      }
      _saved = false;
    });
  }

  void _startEditing() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    _ctrl.clear();
    for (final k in ['name', 'age', 'gender', 'bloodGroup', 'pregnancyStatus', 'pregnancyWeek', 'dueDate']) {
      // Web: the Pregnancy Status input shows "Pregnant" when the stored value is empty.
      final v = k == 'pregnancyStatus' && _profile.pregnancyStatus.isEmpty ? 'Pregnant' : _get(k);
      _ctrl[k] = TextEditingController(text: v);
    }
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    final s = AppStorage.instance;
    await s.saveProfile(_profile);
    final pregnancy = s.readMap(StorageKeys.pregnancyData) ?? <String, dynamic>{};
    // Web: Number(profile.pregnancyWeek) || pregnancy.week || null
    final n = jsNumber(_profile.pregnancyWeek);
    final dynamic week = n != 0 ? (n == n.truncateToDouble() ? n.toInt() : n) : (jsTruthy(pregnancy['week']) ? pregnancy['week'] : null);
    await s.writeJson(StorageKeys.pregnancyData, {...pregnancy, 'week': week});
    if (!mounted) return;
    setState(() {
      _editing = false;
      _saved = true;
    });
  }

  Future<void> _pickDate(TextEditingController c) async {
    final initial = DateTime.tryParse(c.text) ?? DateTime.now();
    final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null) return;
    final v = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    c.text = v;
    _set('dueDate', v);
  }

  Widget _card(String title, List<(String, String, String, String)> items) => ContentCard(
        title: title,
        child: Column(
          children: [
            for (final (name, label, value, type) in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _editing
                    ? TextField(
                        key: ValueKey('profile-$name'),
                        controller: _ctrl[name],
                        readOnly: type == 'date',
                        onTap: type == 'date' ? () => _pickDate(_ctrl[name]!) : null,
                        keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
                        textCapitalization: name == 'name' ? TextCapitalization.words : TextCapitalization.none,
                        decoration: InputDecoration(
                          labelText: label,
                          suffixIcon: type == 'date' ? const Icon(Icons.calendar_today_outlined) : null,
                        ),
                        onChanged: (v) => _set(name, v),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return PageLayout(
      title: 'My Profile',
      eyebrow: 'PATIENT PROFILE',
      activePath: Routes.profile,
      description: 'Keep your personal and health information up to date.',
      children: [
        ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.peachBg,
                  child: Text(p.initials,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('PATIENT ACCOUNT',
                        style: TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    Text(p.name, style: Theme.of(context).textTheme.titleLarge),
                    const Text('ananya.sharma@example.com', style: TextStyle(color: AppColors.muted)),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _editing ? _save : _startEditing,
                  child: Text(_editing ? 'Save Profile' : '✎ Edit Profile'),
                ),
              ),
            ],
          ),
        ),
        if (_saved)
          const Text('Your profile was updated successfully.',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
        _card('👤 Personal Information', [
          ('name', 'Full Name', p.name, 'text'),
          ('age', 'Age', p.age, 'text'),
          ('gender', 'Gender', p.gender, 'text'),
        ]),
        _card('🩸 Blood Group', [('bloodGroup', 'Blood Group', p.bloodGroup, 'text')]),
        _card('🤰 Pregnancy Details', [
          ('pregnancyStatus', 'Pregnancy Status', p.pregnancyStatus.isEmpty ? 'Pregnant' : p.pregnancyStatus, 'text'),
          ('pregnancyWeek', 'Weeks Pregnant', p.pregnancyWeek.isEmpty ? 'Not entered' : p.pregnancyWeek, 'number'),
          ('dueDate', 'Expected Due Date', p.dueDate.isEmpty ? 'Not entered' : p.dueDate, 'date'),
        ]),
      ],
    );
  }
}
