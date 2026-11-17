// --- DATA MODELS ---
class GameCategory {
  final String title;
  final String image;
  final List<Map<String, String>> characters;
  GameCategory({
    required this.title,
    required this.image,
    required this.characters,
  });
}