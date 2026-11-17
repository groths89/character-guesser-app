import 'package:flutter/material.dart';
import '../../../models/data.dart';
import '../../../services/sticker_service.dart';

class StickerBookScreen extends StatefulWidget {
  final List<Map<String, String>>? allCharacters;

  const StickerBookScreen({super.key, this.allCharacters});

  @override
  _StickerBookScreenState createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> {
  List<Map<String, dynamic>> _charactersToDisplay =
      CharacterData.getAllCharacters();
  Set<String> _unlockedIds = {};
  bool _isLoading = true;
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final loadedData = CharacterData.getAllCharacters();
      final unlocked = await StickerService.getUnlockedStickers();

      if (mounted) {
        setState(() {
          _charactersToDisplay = loadedData;
          _unlockedIds = unlocked;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("Error loading sticker book characters: $e");
      debugPrint(stackTrace.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredCharacters {
    if (_selectedCategory == 'ALL') {
      return _charactersToDisplay;
    }
    return _charactersToDisplay.where((c) {
      final cat = (c['category'] ?? '').toString().toUpperCase();
      return cat == _selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F9FF),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00677D)),
        ),
      );
    }

    final totalStickers = _charactersToDisplay.length;
    final unlockedCount = _charactersToDisplay.where((c) {
      final cat = c['category'] ?? '';
      final name = c['name'] ?? '';
      return _unlockedIds.contains('$cat:$name');
    }).length;

    final progressRatio = totalStickers > 0
        ? (unlockedCount / totalStickers)
        : 0.0;
    final progressPercent = (progressRatio * 100).toInt();

    // Extract unique categories for filter pills
    final categories = [
      'ALL',
      ...{
        for (var c in _charactersToDisplay)
          if (c['category'] != null && c['category'].toString().isNotEmpty)
            c['category'].toString().toUpperCase(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sticker Collection',
          style: TextStyle(
            color: Color(0xFF00677D),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          children: [
            // Banner Title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDC003),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Color(0xD9770600), offset: Offset(0, 4)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF6C5000), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'STICKER ALBUM',
                    style: TextStyle(
                      color: Color(0xFF6C5000),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.star, color: Color(0xFF6C5000), size: 18),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '✨ GUESS CHARACTERS TO WIN STICKERS! ✨',
              style: TextStyle(
                color: Color(0xFF00677D),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Progress Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB3EBFF), Colors.white, Color(0xFFDEE8FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00677D).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Medallion Badge
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFDC003),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xD9770600),
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Progress details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: '$unlockedCount ',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111C2D),
                                ),
                                children: [
                                  TextSpan(
                                    text: '/ $totalStickers',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF00677D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$progressPercent% Done',
                                style: const TextStyle(
                                  color: Color(0xFF17BD64),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Candy Bar Progress Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 12,
                            backgroundColor: const Color(0xFFD8E3FB),
                            color: const Color(0xFF17BD64),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF6C5000)
                              : const Color(0xFF111C2D),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFDC003),
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 2-Column Collectible Sticker Grid
            _filteredCharacters.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No stickers found in this category.'),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCharacters.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, i) {
                      final character = _filteredCharacters[i];
                      final category = character['category'] ?? '';
                      final name = character['name'] ?? 'Unknown';
                      final imagePath = character['image'] ?? '';
                      final isUnlocked = _unlockedIds.contains(
                        '$category:$name',
                      );

                      return _StickerCard(
                        name: name,
                        category: category,
                        imagePath: imagePath,
                        isUnlocked: isUnlocked,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  final String name;
  final String category;
  final String imagePath;
  final bool isUnlocked;

  const _StickerCard({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.white
            : const Color(0xFFDEE8FF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00677D).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Status Pill
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFFFDC003)
                    : const Color(0xFFBCC9CE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isUnlocked ? 'UNLOCKED! 🎉' : 'LOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isUnlocked
                      ? const Color(0xFF6C5000)
                      : const Color(0xFF3D494D),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Character Die-Cut Stage
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? const Color(0xFFB3EBFF).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Center(
                child: isUnlocked
                    ? (imagePath.isNotEmpty
                          ? Image.asset(imagePath, fit: BoxFit.contain)
                          : const Icon(
                              Icons.person,
                              size: 44,
                              color: Color(0xFF00677D),
                            ))
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          if (imagePath.isNotEmpty)
                            ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                              child: Opacity(
                                opacity: 0.25,
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Color(0xFF6D797E),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Character Title
          Text(
            isUnlocked ? name : '???',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isUnlocked
                  ? const Color(0xFF111C2D)
                  : const Color(0xFF6D797E),
            ),
          ),

          // Rating/Hint Pill
          const SizedBox(height: 2),
          if (isUnlocked)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 12, color: Color(0xFFFDC003)),
                Icon(Icons.star, size: 12, color: Color(0xFFFDC003)),
                Icon(Icons.star, size: 12, color: Color(0xFFFDC003)),
              ],
            )
          else
            Text(
              category.isNotEmpty ? 'Guess in $category!' : 'Guess to unlock!',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF00677D),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
