class CharacterLoader {
  // This helper builds the Map for you so you don't have to type it 300 times
  static List<Map<String, String>> loadFromFolder(String folderName, List<String> fileNames) {
    return fileNames.map((file) {
      // Automatically turns "buzz_lightyear" into "Buzz Lightyear" for the Reveal
      String cleanName = file
          .replaceAll('_', ' ')
          .split(' ')
          .map((str) => str[0].toUpperCase() + str.substring(1))
          .join(' ');

      return {
        "name": cleanName,
        "image": "assets/characters/$folderName/$file.png",
      };
    }).toList();
  }
}