import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Store user session data
  static Future<bool> saveSession({
    required String token,
    String? userId,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      if (userId != null) {
        await prefs.setString(_userIdKey, userId);
      }
      
      if (email != null) {
        await prefs.setString(_userEmailKey, email);
      }
      
      return true;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get stored user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear session (logout)
  static Future<bool> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      return true;
    } catch (e) {
      print('Error clearing session: $e');
      return false;
    }
  }

  // Get session data as a map
  static Future<Map<String, String?>> getSessionData() async {
    return {
      'token': await getToken(),
      'userId': await getUserId(),
      'email': await getUserEmail(),
    };
  }
}
