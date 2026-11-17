import 'package:shared_preferences/shared_preferences.dart';

class StickerService {
  static const String _key = 'unlocked_stickers';

  // Save a character as "unlocked"
  static Future<void> unlockedSticker(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    // Get current list or empty list if first time
    List<String> unlocked = prefs.getStringList(_key) ?? [];

    if (!unlocked.contains(characterName)) {
      unlocked.add(characterName);
      await prefs.setStringList(_key, unlocked);
    }
  }

  // Check if a specified character is unlocked
  static Future<bool> isUnlocked(String characterName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlocked = prefs.getStringList(_key) ?? [];
    return unlocked.contains(characterName);
  }

  // Get every unlocked character id (e.g. "Category:Name")
  static Future<Set<String>> getUnlockedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  // Get the total count (useful for showing progress)
  static Future<int> getUnlockedCount() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getStringList(_key) ?? []).length;
  }
}
