import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model representing a placed sticker with transformation parameters
class PlacedSticker {
  final String id;
  final String name;
  final String imagePath;
  Offset position;
  double scale;
  double rotation; // In radians

  PlacedSticker({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class StickerSandbox extends StatefulWidget {
  final String backgroundPath;
  final List<Map<String, String>> allCharacters;

  const StickerSandbox({
    super.key,
    this.backgroundPath = 'assets/backgrounds/default_scene.jpg',
    required this.allCharacters,
  });

  @override
  _StickerSandboxState createState() => _StickerSandboxState();
}

class _StickerSandboxState extends State<StickerSandbox> {
  final List<PlacedSticker> _placedStickers = [];
  PlacedSticker? _selectedSticker;
  List<Map<String, String>> _unlockedStickers = [];
  bool _isDrawerOpen = true;

  // Initialized directly to allow runtime switching without LateInitializationError
  String? _customBackgroundPath;

  String get _currentBackgroundPath {
    String path = _customBackgroundPath ?? widget.backgroundPath;
    if (path.isEmpty) {
      path = 'assets/backgrounds/default_scene.jpg';
    }
    // Strip leading slash if present (e.g., '/assets/...' -> 'assets/...')
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return path;
  }

  @override
  void initState() {
    super.initState();
    _loadUnlockedStickers();
  }

  /// Restored & enhanced loader logic to match all storage formats
  Future<void> _loadUnlockedStickers() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Gather all possible unlocked identifiers from preferences
    final Set<String> unlockedKeys = {};

    // Check for standard string list
    final List<String>? unlockedList = prefs.getStringList('unlocked_stickers');
    if (unlockedList != null) {
      unlockedKeys.addAll(unlockedList);
    }

    // Check for individual boolean flags (e.g., 'unlocked_Mario': true).
    // Guard each read since other keys (like the string list above) aren't booleans.
    final allPrefsKeys = prefs.getKeys();
    for (String key in allPrefsKeys) {
      bool? value;
      try {
        value = prefs.getBool(key);
      } catch (_) {
        continue;
      }
      if (value == true) {
        // Strip prefix if the key uses 'unlocked_Name'
        final cleanKey = key.startsWith('unlocked_')
            ? key.replaceFirst('unlocked_', '')
            : key;
        unlockedKeys.add(cleanKey);
        unlockedKeys.add(key); // keep original just in case
      }
    }

    // 2. Filter widget.allCharacters against gathered identifiers
    List<Map<String, String>> earned = widget.allCharacters.where((character) {
      final name = character['name'] ?? '';
      final category = character['category'] ?? '';
      final compositeKey = '$category:$name';

      return unlockedKeys.contains(name) ||
          unlockedKeys.contains(compositeKey) ||
          unlockedKeys.contains('unlocked_$name');
    }).toList();

    // 3. Fallback: If no preferences are stored at all, show all characters so sandbox works out-of-the-box
    if (earned.isEmpty && unlockedKeys.isEmpty) {
      earned = List.from(widget.allCharacters);
    }

    setState(() {
      _unlockedStickers = earned;
    });
  }

  void _addStickerToCanvas(Map<String, String> stickerData) {
    final newSticker = PlacedSticker(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: stickerData['name'] ?? 'Sticker',
      imagePath: stickerData['image'] ?? '',
      position: const Offset(120, 160),
    );

    setState(() {
      _placedStickers.add(newSticker);
      _selectedSticker = newSticker;
    });
  }

  void _clearCanvas() {
    setState(() {
      _placedStickers.clear();
      _selectedSticker = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Interactive Sandbox Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Stack(
                    children: [
                      // Scrollable Canvas Area
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: 800,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              // 1. Scenic Background Image
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedSticker = null),
                                  child: Image.asset(
                                    _currentBackgroundPath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      color: const Color(0xFFDEE8FF),
                                      child: const Center(
                                        child: Icon(
                                          Icons.landscape,
                                          size: 48,
                                          color: Color(0xFF00677D),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 2. Interactive Placed Stickers
                              ..._placedStickers.map((sticker) {
                                final isSelected =
                                    _selectedSticker?.id == sticker.id;
                                return Positioned(
                                  left: sticker.position.dx,
                                  top: sticker.position.dy,
                                  child: _buildInteractiveSticker(
                                    sticker,
                                    isSelected,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      // Restored Top Toolbar Overlay
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: _buildTopToolbar(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Pop-Open Toybox Sticker Drawer Tray
            _buildDrawerTray(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF9F9FF),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Sticker Sandbox',
        style: TextStyle(
          color: Color(0xFF00677D),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFDC003),
            child: const Icon(Icons.person, color: Color(0xFF6C5000), size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTopToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _clearCanvas,
              icon: const Icon(Icons.delete_sweep, color: Color(0xFFBA1A1A)),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFFBCC9CE),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFD8E3FB), offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.layers, size: 16, color: Color(0xFF17BD64)),
                  const SizedBox(width: 4),
                  Text(
                    '${_placedStickers.length} Placed',
                    style: const TextStyle(
                      color: Color(0xFF00677D),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFDC003),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0xFFFABD00), offset: Offset(0, 3)),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.celebration, size: 16, color: Color(0xFF6C5000)),
              SizedBox(width: 4),
              Text(
                'SANDBOX',
                style: TextStyle(
                  color: Color(0xFF6C5000),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveSticker(PlacedSticker sticker, bool isSelected) {
    const double baseSize = 100.0;
    final double effectiveSize = baseSize * sticker.scale;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Main Sticker Drag/Select Body
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() => _selectedSticker = sticker);
          },
          onPanUpdate: (details) {
            setState(() {
              _selectedSticker = sticker;
              sticker.position += details.delta;
            });
          },
          child: Transform.rotate(
            angle: sticker.rotation,
            child: Container(
              width: effectiveSize,
              height: effectiveSize,
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xFFFDC003).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFDC003),
                        width: 2,
                      ),
                    )
                  : null,
              child: Image.asset(
                sticker.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),

        // 2. Control Handles (Positioned outside main GestureDetector)
        if (isSelected) ...[
          // Delete Handle (Top-Left)
          Positioned(
            top: -14,
            left: -14,
            child: _buildHandleButton(
              icon: Icons.close,
              color: const Color(0xFFBA1A1A),
              onTap: () {
                setState(() {
                  _placedStickers.removeWhere((s) => s.id == sticker.id);
                  _selectedSticker = null;
                });
              },
            ),
          ),
          // Rotate Handle (Top-Right)
          Positioned(
            top: -14,
            right: -14,
            child: _buildHandleButton(
              icon: Icons.autorenew,
              color: const Color(0xFFFDC003),
              iconColor: const Color(0xFF6C5000),
              onTap: () {
                setState(() {
                  sticker.rotation += math.pi / 8;
                });
              },
            ),
          ),
          // Scale Handle (Bottom-Right)
          Positioned(
            bottom: -14,
            right: -14,
            child: _buildHandleButton(
              icon: Icons.open_in_full,
              color: const Color(0xFF00677D),
              onTap: () {
                setState(() {
                  sticker.scale = sticker.scale >= 2.0
                      ? 0.8
                      : sticker.scale + 0.3;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHandleButton({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 36, // Larger hit area for easy tapping
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  Widget _buildDrawerTray() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F00677D),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isDrawerOpen = !_isDrawerOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDC003),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'STICKER BOX',
                        style: TextStyle(
                          color: Color(0xFF00677D),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDC003).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_unlockedStickers.length} Unlocked',
                          style: const TextStyle(
                            color: Color(0xFF5B4300),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isDrawerOpen ? Icons.expand_more : Icons.expand_less,
                    color: const Color(0xFF3D494D),
                  ),
                ],
              ),
            ),
          ),
          if (_isDrawerOpen)
            Container(
              height: 110,
              padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: _unlockedStickers.isEmpty
                  ? const Center(
                      child: Text(
                        'No unlocked stickers yet! Play to earn some.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6D797E),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _unlockedStickers.length,
                      itemBuilder: (context, index) {
                        final item = _unlockedStickers[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () => _addStickerToCanvas(item),
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F3FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFD8E3FB),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      item['image'] ?? '',
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, o, s) => const Icon(
                                        Icons.star,
                                        color: Color(0xFFFDC003),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['name'] ?? 'Sticker',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111C2D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
