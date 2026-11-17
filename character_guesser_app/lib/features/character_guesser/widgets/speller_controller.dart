import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class SpellerController extends TextEditingController {
  final String correctName;
  bool isWrongMode = false;

  SpellerController({required this.correctName, this.isWrongMode = false});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // If we aren't in "wrong mode" or the box is empty, draw text normally
    if (!isWrongMode || text.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    List<TextSpan> children = [];
    String userText = text;
    String target = correctName.toLowerCase();

    for (int i = 0; i < userText.length; i++) {
      // If the character matches the one in the correct name at the position
      bool isMatch =
          i < target.length && userText[i].toLowerCase() == target[i];

      children.add(
        TextSpan(
          text: userText[i],
          style: style?.copyWith(
            color: isMatch
                ? Colors.black
                : Colors.red, //Black if right, Red if wrong
            fontWeight: isMatch ? FontWeight.bold : FontWeight.w900,
          ),
        ),
      );
    }
    return TextSpan(style: style, children: children);
  }
}
