import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/illustrations.dart';
import 'category_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Centered stylized avatar with 3D Question Mark
                    Center(
                      child: WelcomeIllustration(
                        size: (size.width * 0.70).clamp(200.0, 320.0),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title & Subtitle matching Figma
                    Column(
                      children: [
                        Text(
                          'Quizzical',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF363B4C),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF363B4C),
                              letterSpacing: 0.2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9EA3B0),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF363B4C), width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Primary CTA Button matching Figma
                    CustomButton(
                      text: 'GET STARTED',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategorySelectionScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
