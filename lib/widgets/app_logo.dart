import 'package:flutter/material.dart';

import '../core/theme.dart';

/// App logo widget displaying the Momucoo circular blood drop & pulse emblem,
/// optionally with the "Momucoo" brand title.
/// Includes an errorBuilder fallback so it never throws or displays an error box.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 28,
    this.showText = false,
    this.fontSize = 18,
    this.textColor = AppColors.primary,
  });

  /// The size (width and height) of the logo icon.
  final double size;

  /// Whether to display the text "Momucoo" beside the logo.
  final bool showText;

  /// Font size for the brand text when [showText] is true.
  final double fontSize;

  /// Text color for the brand text.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final logoImage = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Text('🩸', style: TextStyle(fontSize: size * 0.8)),
    );

    if (!showText) {
      return logoImage;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoImage,
        const SizedBox(width: 8),
        Text(
          'Momucoo',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
