import 'package:flutter/material.dart';
import '../../../models/game_category.dart';
import '../../../models/data.dart';
import '../screens/game_page_screen.dart';
import '../../../core/constants.dart';
import '../widgets/carnival_background.dart';
import '../widgets/category_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int sessionLimit = 5;

  final List<GameCategory> categories = [
    GameCategory(
      title: 'Madagascar',
      image: 'assets/categories/madagascar_poster.png',
      characters: CharacterData.getMadagascar(),
    ),
    GameCategory(
      title: 'Minions',
      image: 'assets/categories/minions_poster.png',
      characters: CharacterData.getMinions(),
    ),
    GameCategory(
      title: 'Toy Story',
      image: 'assets/categories/toy_story_poster.png',
      characters: CharacterData.getToyStory(),
    ),
    GameCategory(
      title: 'Monsters Inc',
      image: 'assets/categories/monsters_inc_poster.png',
      characters: CharacterData.getMonstersInc(),
    ),
    GameCategory(
      title: 'Superheroes',
      image: 'assets/categories/superheroes_poster.png',
      characters: CharacterData.getSuperheroes(),
    ),
    GameCategory(
      title: 'Super Mario',
      image: 'assets/categories/super_mario_poster.png',
      characters: CharacterData.getSuperMario(),
    ),
    GameCategory(
      title: 'Paw Patrol',
      image: 'assets/categories/paw_patrol_poster.png',
      characters: CharacterData.getPawPatrol(),
    ),
    GameCategory(
      title: 'Zootopia',
      image: 'assets/categories/zootopia_poster.png',
      characters: CharacterData.getZootopia(),
    ),
    GameCategory(
      title: 'Cars',
      image: 'assets/categories/cars_poster.jpg',
      characters: CharacterData.getCars(),
    ),
    GameCategory(
      title: 'Pokemon',
      image: 'assets/categories/pokemon_poster.jpg',
      characters: CharacterData.getPokemonCharacters(),
    ),
  ];

  // Visual styling metadata for carnival thematic cards
  final List<Map<String, dynamic>> _cardStyles = [
    {
      'shadow': const Color(0xFFB91C1C),
      'border': AppColors.carnivalSun,
      'gradient': [
        AppColors.carnivalAmber,
        const Color(0xFFEA580C),
        const Color(0xFFDC2626),
      ],
    },
    {
      'shadow': const Color(0xFF0369A1),
      'border': AppColors.carnivalCyan,
      'gradient': [
        AppColors.carnivalSky,
        AppColors.carnivalSkyDeep,
        const Color(0xFF1D4ED8),
      ],
    },
    {
      'shadow': const Color(0xFF1D4ED8),
      'border': AppColors.carnivalSky,
      'gradient': [
        const Color(0xFF1E40AF),
        const Color(0xFF3B82F6),
        AppColors.carnivalSky,
      ],
    },
    {
      'shadow': const Color(0xFF0F766E),
      'border': const Color(0xFF5EEAD4),
      'gradient': [
        const Color(0xFF2DD4BF),
        const Color(0xFF0D9488),
        const Color(0xFF115E59),
      ],
    },
    {
      'shadow': const Color(0xFFE11D48),
      'border': AppColors.carnivalPink,
      'gradient': [
        const Color(0xFFFB7185),
        AppColors.carnivalPink,
        const Color(0xFFBE123C),
      ],
    },
  ];

  void _onCategorySelect(GameCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(category: category, limit: sessionLimit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarnivalBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
        child: Column(
          children: [
            // Explorer Greeting Message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.carnivalSkyDeep.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🦁', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'Hi there, Explorer!',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF78350F),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Step right up and test your movie wits!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Color(0xFF0284C7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Ribbon Banner Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.carnivalAmber,
                    AppColors.carnivalSun,
                    AppColors.carnivalAmber,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(0, 4)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: Color(0xFF78350F), size: 18),
                  SizedBox(width: 6),
                  Text(
                    '🎪 PICK A WORLD TO PLAY 🎪',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF451A03),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.stars, color: Color(0xFF78350F), size: 18),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Category Grid
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (categories.length / 2).ceil(),
              itemBuilder: (context, rowIndex) {
                int firstIdx = rowIndex * 2;
                int secondIdx = firstIdx + 1;

                if (rowIndex == 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: CategoryCard(
                      category: categories[firstIdx],
                      onTap: () => _onCategorySelect(categories[firstIdx]),
                      isWide: true,
                      shadowColor: _cardStyles[2]['shadow'],
                      borderColor: _cardStyles[2]['border'],
                      gradientColors: _cardStyles[2]['gradient'],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: CategoryCard(
                          category: categories[firstIdx],
                          onTap: () => _onCategorySelect(categories[firstIdx]),
                          shadowColor:
                              _cardStyles[firstIdx %
                                  _cardStyles.length]['shadow'],
                          borderColor:
                              _cardStyles[firstIdx %
                                  _cardStyles.length]['border'],
                          gradientColors:
                              _cardStyles[firstIdx %
                                  _cardStyles.length]['gradient'],
                        ),
                      ),
                      const SizedBox(width: 14),
                      if (secondIdx < categories.length)
                        Expanded(
                          child: CategoryCard(
                            category: categories[secondIdx],
                            onTap: () =>
                                _onCategorySelect(categories[secondIdx]),
                            shadowColor:
                                _cardStyles[secondIdx %
                                    _cardStyles.length]['shadow'],
                            borderColor:
                                _cardStyles[secondIdx %
                                    _cardStyles.length]['border'],
                            gradientColors:
                                _cardStyles[secondIdx %
                                    _cardStyles.length]['gradient'],
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
