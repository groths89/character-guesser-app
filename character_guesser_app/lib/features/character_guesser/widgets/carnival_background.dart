import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class CarnivalBackground extends StatelessWidget {
  final Widget child;

  const CarnivalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Sky Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF38BDF8), Color(0xFF60D0FF), Color(0xFFB3EAFF)],
            ),
          ),
        ),
        // Decorative Atmosphere Elements (Clouds & Sparkles)
        Positioned(
          top: -20,
          left: -30,
          child: _buildCloud(width: 200, height: 120),
        ),
        Positioned(
          top: 60,
          right: -40,
          child: _buildCloud(width: 240, height: 130),
        ),
        Positioned(
          top: 80,
          right: 100,
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.carnivalSun.withValues(alpha: 0.8),
            size: 28,
          ),
        ),
        Positioned(
          top: 220,
          left: 30,
          child: const Icon(Icons.star, color: Colors.white, size: 32),
        ),
        // Content Body
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildCloud({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
