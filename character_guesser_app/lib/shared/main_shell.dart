import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'top_header.dart';
import 'bottom_navigation.dart';

// Import your tab destination screens
import '../features/character_guesser/screens/category_selection_screen.dart';
import '../features/number_paint/screens/paint_by_numbers_screen.dart'; // or your theme screen
import '../features/sticker_book/screens/sticker_book_screen.dart';
import '../features/sticker_book/screens/sticker_sandbox_screen.dart';

class MainShell extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> navTap;

  const MainShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.navTap,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const TopHeader(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4BC0F9), Color(0xFF75D4FB), Color(0xFFC7F0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: widget.body,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: widget.currentIndex,
        onTap: widget.navTap,
      ),
    );
  }
}
