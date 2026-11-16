import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Port of frontend/src/pages/PatientProfile.jsx (route /profile).
/// Matches the web app design with avatar header, personal info form,
/// pregnancy info with week & due date, medical history, and save confirmation.
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _weekCtrl = TextEditingController(text: '35');
  final _dueDateCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();

  String _name = 'saraswathi reddy';
  final String _email = 'saraswathi12@gmail.com';
  String _bloodGroup = 'O+';
  bool _currentlyPregnant = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final s = AppStorage.instance;
    final stored = s.profile;
    if (stored != null) {
      if (stored.name.isNotEmpty && stored.name != 'Ananya Sharma') {
        _name = stored.name;
      }
      if (stored.bloodGroup.isNotEmpty) _bloodGroup = stored.bloodGroup;
      if (stored.pregnancyWeek.isNotEmpty) _weekCtrl.text = stored.pregnancyWeek;
      if (stored.dueDate.isNotEmpty) _dueDateCtrl.text = stored.dueDate;
    }
  }

  @override
  void dispose() {
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _weekCtrl.dispose();
    _dueDateCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name.isNotEmpty ? _name.substring(0, 2).toUpperCase() : 'SR';
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        ctrl.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    final s = AppStorage.instance;
    final updated = Profile(
      name: _name,
      age: '24 Years',
      gender: 'Female',
      bloodGroup: _bloodGroup,
      pregnancyStatus: _currentlyPregnant ? 'Pregnant' : 'Not Pregnant',
      pregnancyWeek: _weekCtrl.text.trim(),
      dueDate: _dueDateCtrl.text.trim(),
    );
    await s.saveProfile(updated);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Profile saved successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'My Profile',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      description: 'Manage your personal and pregnancy information',
      activePath: Routes.profile,
      children: [
        if (_saved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 10),
                Text('Profile saved successfully.', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

        // 1. Header Card (Matching web app)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5D4CE)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFFC0392B),
                child: Text(
                  _initials,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 3),
                    Text(_email, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Patient',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC0392B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Personal Information Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5D4CE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: Color(0xFFC0392B), size: 18),
                  SizedBox(width: 8),
                  Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Date of Birth', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _pickDate(_dobCtrl),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCF9F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5D4CE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dobCtrl.text.isEmpty ? 'dd-mm-yyyy' : _dobCtrl.text,
                        style: TextStyle(color: _dobCtrl.text.isEmpty ? const Color(0xFF9CA3AF) : AppColors.ink, fontSize: 14),
                      ),
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFCF9F7),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF9F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5D4CE)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _bloodGroup,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _bloodGroup = v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Pregnancy Information Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5D4CE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pregnant_woman, color: Color(0xFFC0392B), size: 18),
                  SizedBox(width: 8),
                  Text('Pregnancy Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                value: _currentlyPregnant,
                onChanged: (v) => setState(() => _currentlyPregnant = v ?? true),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFC0392B),
                title: const Text('Currently pregnant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_currentlyPregnant) ...[
                const SizedBox(height: 10),
                const Text('Pregnancy Week (1–42)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 6),
                TextField(
                  controller: _weekCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 35',
                    filled: true,
                    fillColor: const Color(0xFFFCF9F7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Expected Delivery Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _pickDate(_dueDateCtrl),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF9F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5D4CE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dueDateCtrl.text.isEmpty ? 'dd-mm-yyyy' : _dueDateCtrl.text,
                          style: TextStyle(color: _dueDateCtrl.text.isEmpty ? const Color(0xFF9CA3AF) : AppColors.ink, fontSize: 14),
                        ),
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 4. Medical History Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5D4CE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Medical History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 8),
              const Text('Known conditions, allergies, or relevant history', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 10),
              TextField(
                controller: _historyCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Iron deficiency anemia in previous pregnancy, thalassemia trait...',
                  filled: true,
                  fillColor: const Color(0xFFFCF9F7),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5D4CE))),
                ),
              ),
            ],
          ),
        ),

        // Save Button
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
