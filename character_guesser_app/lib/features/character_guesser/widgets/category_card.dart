import 'package:flutter/material.dart';
import '../../../models/game_category.dart';
import '../../../core/constants.dart';

class CategoryCard extends StatelessWidget {
  final GameCategory category;
  final VoidCallback onTap;
  final bool isWide;
  final Color shadowColor;
  final Color borderColor;
  final List<Color> gradientColors;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isWide = false,
    required this.shadowColor,
    required this.borderColor,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 10),
              blurRadius: 0,
            ),
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.3),
              offset: const Offset(0, 18),
              blurRadius: 20,
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: isWide ? _buildWideContent() : _buildStandardContent(),
        ),
      ),
    );
  }

  Widget _buildPosterImage({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          category.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if image path is invalid or missing from pubspec.yaml
            return Container(
              color: AppColors.carnivalGold,
              child: const Icon(
                Icons.movie_creation_outlined,
                size: 36,
                color: Color(0xFF451A03),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStandardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category Poster Badge
        _buildPosterImage(size: 76),
        const SizedBox(height: 12),
        // Title
        Text(
          category.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Tag Badges
        _buildBadge(
          '${category.characters.length} Items',
          AppColors.carnivalSun,
          const Color(0xFF451A03),
        ),
      ],
    );
  }

  Widget _buildWideContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white54),
                ),
                child: const Text(
                  '❄️ FEATURED WORLD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.title,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 3),
                      blurRadius: 6,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter a world of magic, fun, and carnival adventure!',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              _buildBadge(
                'EXPLORE',
                AppColors.carnivalCyan,
                const Color(0xFF0F172A),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildPosterImage(size: 88),
      ],
    );
  }

  Widget _buildBadge(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
