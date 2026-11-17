import 'package:flutter/material.dart';

class ArcadeKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String correctName;

  const ArcadeKeyboard({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.correctName,
  });

  static const List<String> _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  // Appends any spaces the target name expects at the current position.
  void _autoAdvanceSpaces() {
    while (controller.text.length < correctName.length &&
        correctName[controller.text.length] == ' ') {
      controller.text += ' ';
    }
  }

  void _onSpace() {
    _autoAdvanceSpaces();
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  void _onKeyPress(String char) {
    if (controller.text.length >= correctName.length) return;
    _autoAdvanceSpaces();
    controller.text += char;
    _autoAdvanceSpaces();
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  void _onBackspace() {
    if (controller.text.isNotEmpty) {
      var text = controller.text.substring(0, controller.text.length - 1);
      while (text.isNotEmpty && text.endsWith(' ')) {
        text = text.substring(0, text.length - 1);
      }
      controller.text = text;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentText = controller.text.toUpperCase();
    final String targetText = correctName.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x380284C7),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double keySize = (constraints.maxWidth - 40) / 6;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final letter = _letters[index];
                  final bool isUsedInCorrect =
                      targetText.contains(letter) &&
                      currentText.contains(letter);

                  return _buildKey(
                    letter: letter,
                    size: keySize,
                    isSuccess: isUsedInCorrect,
                    onTap: () => _onKeyPress(letter),
                  );
                },
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 4),
                  _buildKey(
                    letter: _letters[24], // Y
                    size: keySize,
                    onTap: () => _onKeyPress(_letters[24]),
                  ),
                  const SizedBox(width: 6),
                  _buildKey(
                    letter: _letters[25], // Z
                    size: keySize,
                    onTap: () => _onKeyPress(_letters[25]),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: (keySize * 2) + 6,
                    height: keySize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onSpace,
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFFFFF), Color(0xFFEDF7FF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFBAE6FD),
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.space_bar,
                              color: Color(0xFF0C4A6E),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: (keySize * 2) + 6,
                    height: keySize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onBackspace,
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFF7096),
                                Color(0xFFF43F5E),
                                Color(0xFFBE123C),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF881337),
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.backspace_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKey({
    required String letter,
    required double size,
    required VoidCallback onTap,
    bool isSuccess = false,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: isSuccess
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
                      colors: [Color(0xFFFFFFFF), Color(0xFFEDF7FF)],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: isSuccess
                      ? const Color(0xFF15803D)
                      : const Color(0xFFBAE6FD),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isSuccess ? Colors.white : const Color(0xFF0C4A6E),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
