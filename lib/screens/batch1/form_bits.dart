import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Brand line used on auth pages (Momucoo logo + title).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Text('🩸', style: TextStyle(fontSize: size * 0.75)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Momucoo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      );
}

/// Label above a text field, as the web forms do.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              autocorrect: !obscure,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              autofillHints: autofillHints,
              decoration: InputDecoration(hintText: hint),
            ),
          ],
        ),
      );
}

/// Web `.error.auth-error`.
class AuthError extends StatelessWidget {
  const AuthError(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(message, style: const TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w600)),
      );
}

/// Formats a date like JS toLocaleDateString("en-IN", {day:"2-digit", month:"short", year:"numeric"}).
String formatReportDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
}
