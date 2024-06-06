import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _keyFavorites = 'favorites';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, favorites);
  }

  Future<void> addFavorite(String packageName) async {
    final favorites = await getFavorites();
    favorites.add(packageName);
    await saveFavorites(favorites);
  }

  Future<void> removeFavorite(String packageName) async {
    final favorites = await getFavorites();
    favorites.remove(packageName);
    await saveFavorites(favorites);
  }
}
