import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/illustrations.dart';
import 'category_selection_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final totalQuestions = provider.questions.length;
        final score = provider.score;
        final double accuracy = provider.accuracyPercentage;
        final bool isSuccess = accuracy >= 50.0;
        final int timeInSeconds = provider.totalQuizTimeSeconds;
        final String minutes = (timeInSeconds ~/ 60).toString().padLeft(2, '0');
        final String seconds = (timeInSeconds % 60).toString().padLeft(2, '0');

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _handlePlayAgain(context, provider);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Top Illustration matching Figma Screen 6 & 7
                    Center(
                      child: isSuccess
                          ? const ConfettiIllustration(size: 190)
                          : const ConfigIllustration(size: 170),
                    ),
                    const SizedBox(height: 24),

                    // Title: "Congratulation" or "Keep Trying!"
                    Text(
                      isSuccess ? 'Congratulation' : 'Keep Trying!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Prominent Score Badge matching Figma
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? const Color(0xFFD3F4D9)
                            : const Color(0xFFFFD6D9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSuccess
                              ? const Color(0xFF98E2A7)
                              : const Color(0xFFFF9AA2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSuccess
                                ? const Color(0xFF40916C).withValues(alpha: 0.12)
                                : const Color(0xFFD90429).withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${accuracy.toStringAsFixed(0)}%',
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: isSuccess
                                  ? const Color(0xFF2D6A4F)
                                  : const Color(0xFFD90429),
                            ),
                          ),
                          Text(
                            'You scored $score/$totalQuestions!',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSuccess
                                  ? const Color(0xFF2D6A4F).withValues(alpha: 0.85)
                                  : const Color(0xFFD90429).withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Motivational Subtitle text matching Figma
                    Text(
                      isSuccess
                          ? "You've got a great foundation. Ready to try a different category?"
                          : "Don't give up! Practice makes perfect. Try again to improve your score.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Quick Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.check_circle_outline,
                            iconColor: const Color(0xFF2D6A4F),
                            label: 'Correct',
                            value: '$score',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.cancel_outlined,
                            iconColor: const Color(0xFFD90429),
                            label: 'Incorrect',
                            value: '${totalQuestions - score}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatTile(
                            icon: Icons.timer_outlined,
                            iconColor: AppColors.accentBlue,
                            label: 'Time',
                            value: '${minutes}m ${seconds}s',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // PLAY AGAIN CTA Button matching Figma
                    CustomButton(
                      text: 'PLAY AGAIN',
                      onPressed: () => _handlePlayAgain(context, provider),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlayAgain(BuildContext context, QuizProvider provider) {
    // Resets quiz state while preserving saved config via SharedPreferences
    provider.resetQuiz(keepConfig: true);

    // Navigate cleanly back to CategorySelectionScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CategorySelectionScreen()),
      (route) => route.isFirst,
    );
  }
}
