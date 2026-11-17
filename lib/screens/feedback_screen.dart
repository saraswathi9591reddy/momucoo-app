import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Matches frontend/src/pages/Feedback.jsx
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 5;
  String _category = 'General Experience';
  final _commentController = TextEditingController();
  bool _submitted = false;

  static const List<String> categories = [
    'General Experience',
    'CBC Report OCR Scanning',
    'Risk Level & Recommendations',
    'Knowledge Hub & Educational Guides',
    'Other / Feature Request',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Feedback & Suggestions',
      eyebrow: 'MOMUCOO • PATIENT PORTAL',
      activePath: Routes.feedback,
      description: 'Help us make pregnancy anemia screening simpler and more supportive for mothers everywhere.',
      children: [
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _submitted
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4EDDA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Color(0xFF155724), size: 36),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Thank You for Your Feedback!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your suggestions help us refine our screening flow and educational guidance for expectant mothers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            _submitted = false;
                            _commentController.clear();
                          });
                        },
                        child: const Text('Submit Another Response', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDEDEC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Share Your Experience',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                'Takes less than 1 minute',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Rating Stars
                      const Text(
                        'Overall App Rating:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 32,
                              icon: Icon(
                                i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: i <= _rating ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                              ),
                              onPressed: () => setState(() => _rating = i),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      const Text(
                        'What is this about?',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                        ),
                        isExpanded: true,
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Comments Text Area
                      const Text(
                        'Your Comments or Suggestions:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tell us what you liked or what we can improve...',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                          ),
                          onPressed: _handleSubmit,
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
