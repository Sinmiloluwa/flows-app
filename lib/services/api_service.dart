import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flows/services/session_service.dart';

class ApiService {
  static const String baseUrl = 'https://flows-backend.onrender.com/api';

  // Get headers with authentication token
  static Future<Map<String, String>> _getHeaders(
      {bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await SessionService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Make authenticated GET request
  static Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final requestHeaders = await _getHeaders();

    // Merge custom headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.get(uri, headers: requestHeaders);
  }

  // Make authenticated POST request
  static Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // Make authenticated PUT request
  static Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  // Make authenticated DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.delete(uri, headers: headers);
  }

  // Login request (doesn't need authentication)
  static Future<http.Response> login(String email, String password) async {
    final headers = await _getHeaders(includeAuth: false);
    final uri = Uri.parse('$baseUrl/auth/login');

    return await http.post(
      uri,
      headers: headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
  }

  // Signup request (doesn't need authentication)
  static Future<http.Response> signup(String email, String password,
      {String? name}) async {
    final headers = await _getHeaders(includeAuth: false);
    final uri = Uri.parse('$baseUrl/auth/signup');

    Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
    };

    if (name != null) {
      requestBody['name'] = name;
    }

    return await http.post(
      uri,
      headers: headers,
      body: json.encode(requestBody),
    );
  }

  // Logout and clear session
  static Future<bool> logout() async {
    try {
      // You can make a logout API call here if your backend requires it
      // await post('/auth/logout');

      // Clear local session
      return await SessionService.clearSession();
    } catch (e) {
      print('Error during logout: $e');
      // Even if API call fails, clear local session
      return await SessionService.clearSession();
    }
  }

  // Check if token is still valid by making a test request
  static Future<bool> validateToken() async {
    try {
      final response = await get('/auth/validate'); // Adjust endpoint as needed
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // Fetch categories (authenticated request)
  static Future<http.Response> getCategories() async {
    return await get('/categories');
  }

  // Fetch songs by category (authenticated request)
  static Future<http.Response> getSongsByCategory(String categoryId) async {
    return await get('/categories/$categoryId/songs');
  }

  // Fetch user's playlists (authenticated request)
  static Future<http.Response> getPlaylists() async {
    final headers = await _getHeaders();
    return await get('/playlists', headers: headers);
  }

  // Create a new playlist (authenticated request)
  static Future<http.Response> createPlaylist(String name,
      {String? description}) async {
    Map<String, dynamic> requestBody = {
      'name': name,
    };

    if (description != null) {
      requestBody['description'] = description;
    }

    return await post('/playlists', body: requestBody);
  }

  // Fetch popular songs (authenticated request)
  static Future<http.Response> getPopularSongs({int limit = 10}) async {
    return await get('/songs/popular?limit=$limit');
  }

  static Future<http.Response> getSongById(String songId) async {
    print('API: Fetching song with ID: $songId');
    print('API: Endpoint: /songs/$songId');
    return await get('/songs/$songId');
  }

  // Search for songs (authenticated request)
  static Future<http.Response> searchSongs(String query) async {
    return await get('/songs/search?q=${Uri.encodeComponent(query)}');
  }

  // Get user profile (authenticated request)
  static Future<http.Response> getUserProfile() async {
    return await get('/user/profile');
  }

  // Update user profile (authenticated request)
  static Future<http.Response> updateUserProfile(
      Map<String, dynamic> profileData) async {
    return await put('/user/profile', body: profileData);
  }
}
