import 'package:flows/main.dart';
import 'package:flows/services/api_service.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../views/pages/login_page.dart';

class PlaylistService {
  static Future<List<Map<String, dynamic>>> loadMadeForYou() async {
    final playlists = await ApiService.madeForYou();
    print('status code: ${playlists.statusCode}');
    if (playlists.statusCode == 401) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }

      return [];
    }
    if (playlists.statusCode == 200) {
      final decoded = json.decode(playlists.body);
      final List<dynamic> data = decoded is List
          ? decoded
          : (decoded['playlists'] ?? decoded['data'] ?? []);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}
