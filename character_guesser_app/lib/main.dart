// main.dart
import 'package:flutter/material.dart';
import 'core/themes.dart';
import 'shared/main_shell.dart';
import './models/data.dart';

// Screen imports
import 'features/character_guesser/screens/category_selection_screen.dart';
import 'features/number_paint/screens/paint_by_numbers_screen.dart';
import 'features/sticker_book/screens/sticker_book_screen.dart';
import 'features/sticker_book/screens/sticker_sandbox_screen.dart';

void main() => runApp(const CharacterGuesserApp());

class CharacterGuesserApp extends StatefulWidget {
  const CharacterGuesserApp({super.key});

  @override
  State<CharacterGuesserApp> createState() => _CharacterGuesserAppState();
}

class _CharacterGuesserAppState extends State<CharacterGuesserApp> {
  int _navigationIndex = 0;
  // Bumped on tab changes so sticker screens reload newly unlocked stickers.
  int _refreshTick = 0;
  int _sandboxTick = 0;

  // Root screens for the bottom navigation tabs
  List<Widget> get _screens => [
    CategoryScreen(),
    PaintByNumbersScreen(allCharacters: CharacterData.getAllCharacters()),
    StickerBookScreen(
      key: ValueKey('book-$_refreshTick'),
      allCharacters: CharacterData.getAllCharacters(),
    ),
    StickerSandbox(
      key: ValueKey('sandbox-$_sandboxTick'),
      backgroundPath: '',
      allCharacters: CharacterData.getAllCharacters(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.carnivalTheme,
      home: MainShell(
        currentIndex: _navigationIndex,
        navTap: (index) {
          setState(() {
            _refreshTick++;
            // Reload the sandbox only after returning from the game tab.
            if (_navigationIndex == 0 && index != 0) _sandboxTick++;
            _navigationIndex = index;
          });
        },
        // Dynamically pass the current screen based on the index
        body: IndexedStack(index: _navigationIndex, children: _screens),
      ),
    );
  }
}
