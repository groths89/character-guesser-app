import 'package:flutter/material.dart';
import '../core/constants.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // Only apply safe area inset to the bottom notch
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(48),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D0284C7),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.videogame_asset, 'Play'),
            _buildNavItem(1, Icons.format_paint, 'Paint'),
            _buildNavItem(2, Icons.auto_awesome_motion, 'Collection'),
            _buildNavItem(3, Icons.draw, 'Sandbox'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
            padding: EdgeInsets.all(isSelected ? 10 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.carnivalSun, AppColors.carnivalGold],
                    )
                  : null,
              color: isSelected ? null : AppColors.surfaceContainer,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [const BoxShadow(color: Color(0x8C22C55E), blurRadius: 18)]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF451A03)
                  : AppColors.carnivalSkyDeep,
              size: isSelected ? 26 : 22,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.carnivalSkyDeep : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
