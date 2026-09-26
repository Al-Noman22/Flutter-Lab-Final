import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/illustrations.dart';
import 'quiz_play_screen.dart';

class QuizConfigScreen extends StatelessWidget {
  const QuizConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            final category = provider.selectedCategory;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Illustration from Figma Screen 3 (Gears & Toggles with hand)
                  const Center(
                    child: ConfigIllustration(size: 150),
                  ),
                  const SizedBox(height: 16),

                  // App Title & Configuration Header
                  Text(
                    'Quizzical',
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configuration',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: (category?.accentColor ?? AppColors.primaryTeal).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category?.name ?? 'General Knowledge',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: category?.accentColor ?? AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 1. Number of Questions (Slider matching Figma)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of Questions',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select 1–50',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${provider.amount}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.accentBlue,
                          inactiveTrackColor: AppColors.accentBlue.withValues(alpha: 0.18),
                          thumbColor: AppColors.accentBlue,
                          overlayColor: AppColors.accentBlue.withValues(alpha: 0.12),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: provider.amount.toDouble(),
                          min: 1,
                          max: 50,
                          divisions: 49,
                          onChanged: (val) => provider.setAmount(val.round()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Difficulty Level Dropdown
                  _buildDropdownSection(
                    title: 'Difficulty Level',
                    value: provider.difficulty,
                    items: const ['Any Difficulty', 'Easy', 'Medium', 'Hard'],
                    onChanged: (val) {
                      if (val != null) provider.setDifficulty(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Question Type Dropdown
                  _buildDropdownSection(
                    title: 'Question Type',
                    value: provider.questionType,
                    items: const ['Multiple Choice', 'True / False'],
                    onChanged: (val) {
                      if (val != null) provider.setQuestionType(val);
                    },
                  ),
                  const SizedBox(height: 36),

                  // Error notification if questions fetch failed
                  if (provider.questionError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB3B8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFD90429), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.questionError!,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: const Color(0xFFD90429),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // START Button matching Figma
                  CustomButton(
                    text: 'START',
                    isOutlined: true,
                    isLoading: provider.isLoadingQuestions,
                    onPressed: () async {
                      final success = await provider.startQuiz();
                      if (context.mounted && success) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizPlayScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardNeutralBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
