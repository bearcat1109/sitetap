import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _keyPrefix = 'player_';
  
  // Save player data
  static Future<void> savePlayerData({
    required int playerIndex,
    required int avatarId,
    String? playerName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPrefix${playerIndex}_avatar', avatarId);
    if (playerName != null) {
      await prefs.setString('$_keyPrefix${playerIndex}_name', playerName);
    }
  }
  
  // Load player leader
  static Future<int?> getPlayerAvatar(int playerIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyPrefix${playerIndex}_leader');
  }
  
  // Load player name
  static Future<String?> getPlayerName(int playerIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyPrefix${playerIndex}_name');
  }
}