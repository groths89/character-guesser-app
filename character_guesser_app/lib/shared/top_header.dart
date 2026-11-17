// top_header.dart
import 'package:flutter/material.dart';
import '../core/constants.dart';

class TopHeader extends StatelessWidget implements PreferredSizeWidget {
  final int level;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const TopHeader({
    super.key,
    this.level = 1,
    this.title = 'Character Guessing',
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border(
          bottom: BorderSide(
            color: AppColors.carnivalGold.withValues(alpha: 0.6),
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260284C7),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Icon Button (Hamburger on Root, Back Arrow on Game Page)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), AppColors.carnivalSkyDeep],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.carnivalSkyDeep,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        showBackButton ? Icons.arrow_back : Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed:
                          onBackPressed ??
                          () {
                            if (showBackButton) {
                              Navigator.of(context).pop();
                            }
                          },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Title wrapped in Flexible to avoid overflow
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.carnivalSkyDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.carnivalGold,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      '★ LVL $level',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF451A03),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Profile Avatar
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.carnivalAmber, AppColors.carnivalSun],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.face, color: AppColors.carnivalSkyDeep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
