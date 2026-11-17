import 'package:flutter/material.dart';

import '../core/localization.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/page_layout.dart';

/// Fully localized Feedback screen.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 5;
  int _categoryIndex = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() => setState(() => _submitted = true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, __) {
        final L = LocalizationService.tr;

        final categories = [
          L('fb_cat_general'),
          L('fb_cat_cbc'),
          L('fb_cat_risk'),
          L('fb_cat_knowledge'),
          L('fb_cat_other'),
        ];

        return PageLayout(
          title: L('feedback'),
          eyebrow: L('patient_portal'),
          activePath: Routes.feedback,
          description: L('feedback_desc'),
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
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: _submitted
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(color: Color(0xFFD4EDDA), shape: BoxShape.circle),
                            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF155724), size: 36),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            L('thank_you_feedback'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            L('feedback_thanks_desc'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => setState(() { _submitted = false; _commentController.clear(); }),
                            child: Text(L('submit_another'), style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: const Color(0xFFFDEDEC), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.feedback_outlined, color: Color(0xFFC0392B), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(L('share_your_feedback'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                    Text(L('feedback_subtitle'), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 20),

                          // Star Rating
                          Text(L('rate_experience'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
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

                          // Category
                          Text(L('what_is_this_about'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _categoryIndex,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                            ),
                            isExpanded: true,
                            items: List.generate(
                              categories.length,
                              (i) => DropdownMenuItem(value: i, child: Text(categories[i], style: const TextStyle(fontSize: 14))),
                            ),
                            onChanged: (val) { if (val != null) setState(() => _categoryIndex = val); },
                          ),
                          const SizedBox(height: 20),

                          // Comments
                          Text(L('your_comments'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: L('comment_placeholder'),
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit
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
                              label: Text(L('submit_feedback'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
