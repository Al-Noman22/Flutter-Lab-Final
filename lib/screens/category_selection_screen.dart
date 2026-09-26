import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/shimmer_box.dart';
import 'quiz_config_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Quizzical',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF363B4C),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF363B4C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Text(
                    'choose a category to focus on:',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9EA3B0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error State with Retry Banner
                if (provider.categoryError != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFB3B8), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFD90429)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                provider.categoryError!,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFD90429),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchCategories(forceRefresh: true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD90429),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(120, 44),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content: Skeleton loading or Category Grid
                Expanded(
                  child: provider.isLoadingCategories
                      ? _buildSkeletonLoading()
                      : _buildCategoryGrid(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Skeleton shimmer loader while fetching categories
  Widget _buildSkeletonLoading() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 2),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: Center(
                  child: ShimmerBox(width: 80, height: 80, borderRadius: 16),
                ),
              ),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 16, borderRadius: 8),
            ],
          ),
        );
      },
    );
  }

  /// 2-Column Responsive Grid of Category Cards
  Widget _buildCategoryGrid(BuildContext context, QuizProvider provider) {
    final categories = provider.categories;

    if (categories.isEmpty && provider.categoryError == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.category_outlined, size: 48, color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            Text(
              'No categories found',
              style: GoogleFonts.outfit(
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                color: AppColors.textDark
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => provider.fetchCategories(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Refresh'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryTeal,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      onRefresh: () => provider.fetchCategories(forceRefresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(
            category: category,
            onTap: () {
              provider.selectCategory(category);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizConfigScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Abstract floating circle
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: category.accentColor.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        // Abstract rotated rounded rectangle
                        Positioned(
                          left: -12,
                          bottom: -5,
                          child: Transform.rotate(
                            angle: 0.35,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: category.accentColor.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                        ),
                        // Glassmorphic central bubble with Icon
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.6),
                            boxShadow: [
                              BoxShadow(
                                color: category.accentColor.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              category.icon,
                              size: 40,
                              color: category.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.shortName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF363B4C),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
