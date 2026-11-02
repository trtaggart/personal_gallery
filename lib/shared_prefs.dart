import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAsync {
  Future<SharedPreferences> get instance async => await SharedPreferences.getInstance();

  Future<String?> getString(String key) async {
    final prefs = await instance;
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await instance;
    await prefs.setString(key, value);
  }
}
//String kUri = 'http://192.168.4.44:8080'; //as Future<String>;
