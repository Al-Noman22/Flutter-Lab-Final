import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'results_screen.dart';

class QuizPlayScreen extends StatelessWidget {
  const QuizPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final currentQ = provider.currentQuestion;
        final totalQuestions = provider.questions.length;
        final currentIndex = provider.currentIndex;

        // If quiz completed, redirect to ResultsScreen
        if (provider.isQuizFinished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResultsScreen()),
            );
          });
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
          );
        }

        if (currentQ == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No questions available.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _showExitDialog(context, provider);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Navigation Bar matching Figma
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Per-question Timer Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: provider.timerSeconds <= 5
                                ? const Color(0xFFFFECEF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: provider.timerSeconds <= 5
                                  ? const Color(0xFFFF4D6D)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: provider.timerSeconds <= 5
                                    ? const Color(0xFFFF4D6D)
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.timerSeconds}s',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: provider.timerSeconds <= 5
                                      ? const Color(0xFFFF4D6D)
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Center: Question Counter (e.g., 7/10)
                        Text(
                          '${currentIndex + 1}/$totalQuestions',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),

                        // Right: EXIT Button with Icon matching Figma
                        InkWell(
                          onTap: () => _showExitDialog(context, provider),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  'EXIT',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: AppColors.textDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Bar below Top Row
                  LinearProgressIndicator(
                    value: provider.progressPercentage,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                    minHeight: 4,
                  ),

                  // Scrollable Question & Options Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question Card matching Figma
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        currentQ.difficulty.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentBlue,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      currentQ.category,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  currentQ.question,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Answers list
                          ...currentQ.allAnswers.map((answer) {
                            return _buildOptionCard(
                              answer: answer,
                              question: currentQ,
                              onTap: () {
                                if (!currentQ.isAnswered) {
                                  provider.selectAnswer(answer);
                                }
                              },
                            );
                          }),

                          // Timeout feedback if user ran out of time
                          if (currentQ.isTimedOut)
                            Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer_off_outlined, color: Color(0xFFD90429), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Time expired! Correct answer revealed above.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFD90429),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Next Button matching Figma
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: CustomButton(
                      text: provider.isLastQuestion ? 'View Results' : 'Next',
                      onPressed: provider.isAnswerSubmitted
                          ? () {
                              if (provider.isLastQuestion) {
                                provider.nextQuestion();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ResultsScreen()),
                                );
                              } else {
                                provider.nextQuestion();
                              }
                            }
                          : null, // Disabled until option is selected or timer expires
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Option Card with states: neutral, correct (green), incorrect (red)
  Widget _buildOptionCard({
    required String answer,
    required dynamic question,
    required VoidCallback onTap,
  }) {
    final bool isAnswered = question.isAnswered;
    final bool isSelected = question.selectedAnswer == answer;
    final bool isCorrect = answer == question.correctAnswer;

    Color bgColor = const Color(0xFFF3F5F7);
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.textDark;
    Widget trailingIcon = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
      ),
    );

    if (isAnswered) {
      if (isCorrect) {
        // Correct Answer Styling (Mint Green with Checkmark)
        bgColor = const Color(0xFFC8E6C9);
        borderColor = const Color(0xFF81C784);
        textColor = const Color(0xFF1B5E20);
        trailingIcon = Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF2E7D32),
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        );
      } else if (isSelected && !isCorrect) {
        // Chosen Wrong Answer Styling (Soft Coral with 'X')
        bgColor = const Color(0xFFFFCDD2);
        borderColor = const Color(0xFFE57373);
        textColor = const Color(0xFFB71C1C);
        trailingIcon = Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFC62828),
          ),
          child: const Icon(Icons.close, size: 16, color: Colors.white),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    answer,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: isSelected || (isAnswered && isCorrect)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirm exit dialog
  Future<bool> _showExitDialog(BuildContext context, QuizProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Quiz?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to exit? Your current progress will be lost.',
          style: GoogleFonts.outfit(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD90429),
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 40),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (result == true) {
      provider.exitQuiz();
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true;
    }
    return false;
  }
}
