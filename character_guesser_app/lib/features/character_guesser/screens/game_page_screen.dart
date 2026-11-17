import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants.dart';
import '../../../models/game_category.dart';
import '../widgets/speller_controller.dart';
import '../widgets/arcade_keyboard.dart';
import '../../../services/sticker_service.dart';

class GamePage extends StatefulWidget {
  final GameCategory category;
  final int limit;

  const GamePage({super.key, required this.category, required this.limit});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<Map<String, String>> _gameCharacters;
  int _currentIndex = 0;
  int _turnsTaken = 0;
  bool _isRevealed = false;
  late TextEditingController _guessController;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isWarmingUp = false;
  int _hintLevel = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _gameCharacters = widget.category.characters.toList()..shuffle();
    _guessController = SpellerController(
      correctName: _gameCharacters[_currentIndex]['name']!,
    );
    _guessController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  int _getLevenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j < v0.length; j++) v0[j] = v1[j];
    }

    return v1[s2.length];
  }

  bool _isGuessCorrect(String guess, String correctName) {
    guess = guess.trim().toLowerCase();
    correctName = correctName.toLowerCase();

    if (guess.isEmpty) return false;
    if (guess == correctName) return true;

    String cleanGuess = guess.replaceAll(RegExp(r'[^a-z0-9]'), '');
    String cleanName = correctName.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleanGuess == cleanName) return true;

    int distance = _getLevenshteinDistance(cleanGuess, cleanName);
    int allowedMistakes = cleanName.length > 5 ? 2 : 1;
    if (distance <= allowedMistakes) return true;

    List<String> nameWords = correctName.split(RegExp(r'[^a-z0-9]+'));
    if (nameWords.contains(guess)) return true;

    return false;
  }

  void _checkGuess() {
    final String correctName = _gameCharacters[_currentIndex]['name']!;
    final String userGuess = _guessController.text;
    _speech.stop();
    _audioPlayer.stop();

    if (_isGuessCorrect(userGuess, correctName)) {
      setState(() {
        _isRevealed = true;
      });
      final uniqueId = "${widget.category.title}:$correctName";
      StickerService.unlockedSticker(uniqueId);
    } else {
      setState(() {
        (_guessController as SpellerController).isWrongMode = true;
      });
    }
  }

  void _handleNext() {
    _speech.stop();
    _audioPlayer.stop();
    setState(() {
      _turnsTaken++;
      _isListening = false;
      _isWarmingUp = false;
      if (_turnsTaken >= widget.limit) {
        _showEndDialog();
      } else {
        _currentIndex = (_currentIndex + 1) % _gameCharacters.length;
        _guessController = SpellerController(
          correctName: _gameCharacters[_currentIndex]['name']!,
          isWrongMode: false,
        );
        _guessController.addListener(() {
          setState(() {});
        });
        _isRevealed = false;
        _hintLevel = 0;
      }
    });
  }

  void _showHint() {
    if (_isRevealed) return;
    setState(() {
      _hintLevel = _hintLevel >= 2 ? 1 : _hintLevel + 1;
    });
  }

  String _hintText(String name) {
    final words = name.split(' ');
    if (_hintLevel == 1) {
      return 'Starts with "${name[0].toUpperCase()}" • '
          '${words.length} ${words.length == 1 ? 'word' : 'words'}';
    }
    return words
        .map((w) => w[0].toUpperCase() + ' _' * (w.length - 1))
        .join('   ');
  }

  void _playSoundHint() {
    final String? soundPath = _gameCharacters[_currentIndex]['sound'];
    if (soundPath != null && soundPath.isNotEmpty) {
      String path = soundPath.startsWith('assets/')
          ? soundPath.substring(7)
          : soundPath;
      _audioPlayer.play(AssetSource(path));
    }
  }

  void _listen() async {
    if (_isListening || _isWarmingUp) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _isWarmingUp = false;
      });
      return;
    }

    setState(() => _isWarmingUp = true);

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          setState(() {
            _isWarmingUp = false;
            _isListening = true;
          });
        }
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _isWarmingUp = false;
          });
        }
      },
      onError: (_) {
        setState(() {
          _isListening = false;
          _isWarmingUp = false;
        });
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            if (result.recognizedWords.isNotEmpty) {
              _guessController.text = result.recognizedWords;
            }
            if (result.finalResult) {
              _isListening = false;
              Future.delayed(const Duration(milliseconds: 500), () {
                _checkGuess();
              });
            }
          });
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 4),
        listenOptions: SpeechListenOptions(listenMode: ListenMode.confirmation),
      );
    } else {
      setState(() => _isWarmingUp = false);
    }
  }

  void _showEndDialog() {
    bool isBedtime = DateTime.now().hour >= 19 || DateTime.now().hour < 7;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.carnivalGold, width: 4),
        ),
        title: Text(
          isBedtime ? "🌙 Bedtime!" : "☀️ All Done!",
          style: const TextStyle(
            color: AppColors.carnivalPink,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          isBedtime ? "Time to go to bed." : "Great guessing! Let's go play.",
          style: const TextStyle(
            color: AppColors.carnivalPink,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.carnivalLime,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text(
              "FINISH",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String correctName = _gameCharacters[_currentIndex]['name']!;
    final String userText = _guessController.text.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4BC0F9), Color(0xFF75D4FB), Color(0xFFC7F0FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF0284C7),
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "🎪 ${widget.category.title}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0284C7),
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
                              color: const Color(0xFFFDC003),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text(
                              "★ LVL 1",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF78350F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.carnivalGold,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.face, color: Color(0xFF0284C7)),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Instruction Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFBBF24),
                              Color(0xFFFDE047),
                              Color(0xFFFBBF24),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x59D97706),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help,
                              color: Color(0xFF78350F),
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "WHO IS THIS?",
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF78350F),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text("✨", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Central Character Portal Frame
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFFFFE066),
                                  Color(0xFFF59E0B),
                                  Color(0xFFD97706),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: const Color(0xFFFFFAE6),
                                width: 5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF38BDF8),
                                  spreadRadius: 6,
                                ),
                                BoxShadow(
                                  color: Color(0x9900E5FF),
                                  blurRadius: 25,
                                ),
                                BoxShadow(
                                  color: Color(0x590E7490),
                                  blurRadius: 32,
                                  offset: Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    Color(0xFFCFFAFE),
                                    Color(0xFFA5F3FC),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(44),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF0F9FF),
                                      Color(0xFFE0F2FE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(36),
                                  border: Border.all(
                                    color: const Color(0xFF7DD3FC),
                                    width: 4,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.asset(
                                    _gameCharacters[_currentIndex]['image']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Hint Lightbulb Button (Left)
                          Positioned(
                            left: -20,
                            child: _buildIconButton(
                              icon: Icons.lightbulb,
                              gradientColors: const [
                                Color(0xFFFF176),
                                Color(0xFFFDC003),
                                Color(0xFFE69500),
                              ],
                              shadowColor: const Color(0xFFB26A00),
                              iconColor: const Color(0xFF78350F),
                              onTap: _showHint,
                            ),
                          ),
                          // Sound Button (Right)
                          Positioned(
                            right: -20,
                            child: _buildIconButton(
                              icon: Icons.volume_up,
                              gradientColors: const [
                                Color(0xFFA5F3FC),
                                Color(0xFF00C6FF),
                                Color(0xFF0284C7),
                              ],
                              shadowColor: const Color(0xFF0369A1),
                              iconColor: Colors.white,
                              onTap: _playSoundHint,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Wordle-style Text Display Tiles
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(correctName.length, (
                              index,
                            ) {
                              final String targetChar = correctName[index];

                              // Handle space characters between words
                              if (targetChar == ' ') {
                                return const SizedBox(width: 14);
                              }

                              final bool hasTyped = index < userText.length;
                              final String char = hasTyped
                                  ? userText[index]
                                  : '';
                              final bool isCurrent = index == userText.length;

                              // Calculate dynamic box size for extra long names
                              final double boxSize = correctName.length > 10
                                  ? 40.0
                                  : 48.0;
                              final double fontSize = correctName.length > 10
                                  ? 20.0
                                  : 24.0;

                              return Container(
                                width: boxSize,
                                height: boxSize,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: hasTyped
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF86EFAC),
                                            Color(0xFF22C55E),
                                            Color(0xFF16A34A),
                                          ],
                                        )
                                      : const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFFFFFFF),
                                            Color(0xFFF0F9FF),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrent
                                        ? const Color(0xFFFBBF24)
                                        : Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: hasTyped
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFFF59E0B),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    char.isEmpty && isCurrent ? '_' : char,
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w900,
                                      color: hasTyped
                                          ? Colors.white
                                          : const Color(0xFF0369A1),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      if (_hintLevel > 0 && !_isRevealed) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7CC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFDC003),
                              width: 3,
                            ),
                          ),
                          child: Text(
                            _hintText(correctName),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Candy Arcade Keyboard
                      if (!_isRevealed)
                        ArcadeKeyboard(
                          controller: _guessController,
                          onSubmitted: _checkGuess,
                          correctName: correctName,
                        ),

                      const SizedBox(height: 12),

                      // Submit Action Button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isRevealed ? _handleNext : _checkGuess,
                            borderRadius: BorderRadius.circular(30),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFF6EA7),
                                    Color(0xFFFF2A75),
                                    Color(0xFFD8004E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF9E0039),
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isRevealed ? "NEXT" : "SUBMIT",
                                    style: const TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    _isRevealed
                                        ? Icons.arrow_forward_rounded
                                        : Icons.check_circle,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Text(
                              "${_turnsTaken + 1}/${widget.limit}",
                              style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0C4A6E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 14,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      ((_turnsTaken + 1) / widget.limit).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFBBF24),
                                          Color(0xFFFDC003),
                                          Color(0xFF22C55E),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text("🌟", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Shell Bar
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  top: 4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D0284C7),
                      blurRadius: 28,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.videogame_asset,
                      label: "Play",
                      isSelected: true,
                    ),
                    _buildNavItem(
                      icon: Icons.category,
                      label: "Themes",
                      isSelected: false,
                    ),
                    _buildNavItem(
                      icon: Icons.auto_awesome_motion,
                      label: "Collection",
                      isSelected: false,
                    ),
                    _buildNavItem(
                      icon: Icons.draw,
                      label: "Sandbox",
                      isSelected: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening
            ? AppColors.carnivalPink
            : AppColors.carnivalCyan,
        child: Icon(
          _isListening ? Icons.stop_circle : Icons.mic,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: shadowColor, offset: const Offset(0, 5)),
              ],
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 26)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: Offset(0, isSelected ? -10 : 0),
          child: Container(
            padding: EdgeInsets.all(isSelected ? 10 : 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFDE047), Color(0xFFFDC003)],
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFE0F2FE),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? const [BoxShadow(color: Color(0x8CF59E0B), blurRadius: 16)]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF78350F)
                  : const Color(0xFF0284C7),
              size: isSelected ? 24 : 20,
            ),
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isSelected
                ? const Color(0xFF0C4A6E)
                : const Color(0xFF0284C7).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
