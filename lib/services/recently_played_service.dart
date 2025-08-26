import 'package:flows/services/session_service.dart';
import 'package:flows/views/pages/login_page.dart';
import 'package:flows/main.dart'; // Import to access navigatorKey
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flows/services/api_service.dart';
import 'dart:convert';

class RecentlyPlayedService {
  static const String _recentlyPlayedKey = 'recently_played_songs';
  static const int _maxLocalSongs = 50;

  // Handle 401 authentication errors
  static Future<void> _handleAuthError() async {
    try {
      print('Session expired. Please log in again.');
      await SessionService.clearSession();

      // Use global navigator key to navigate
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (error) {
      print('Error handling auth error: $error');
    }
  }

  // Add a song to recently played (local + backend)
  static Future<void> addSong(Map<String, dynamic> song) async {
    try {
      // Add to local storage first for immediate UI update
      await _addToLocal(song);

      // Send to backend
      final songId = song['id']?.toString() ?? song['_id']?.toString();
      if (songId != null) {
        final response = await ApiService.addRecentlyPlayed(songId);

        if (response.statusCode == 401) {
          await _handleAuthError();
          return;
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Successfully added to recently played: ${song['title']}');
        } else {
          print('Failed to sync recently played: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error adding to recently played: $error');
    }
  }

  // Add to local storage
  static Future<void> _addToLocal(Map<String, dynamic> song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentSongs = await getLocalRecentlyPlayed();

      // Remove if already exists (to move to top)
      final songId = song['id']?.toString() ?? song['_id']?.toString();
      recentSongs.removeWhere(
          (s) => (s['id']?.toString() ?? s['_id']?.toString()) == songId);

      // Add to beginning with timestamp
      final songWithTimestamp = Map<String, dynamic>.from(song);
      songWithTimestamp['playedAt'] = DateTime.now().toIso8601String();
      recentSongs.insert(0, songWithTimestamp);

      // Keep only last N songs
      if (recentSongs.length > _maxLocalSongs) {
        recentSongs.removeRange(_maxLocalSongs, recentSongs.length);
      }

      // Save to preferences
      final jsonString = json.encode(recentSongs);
      await prefs.setString(_recentlyPlayedKey, jsonString);
    } catch (error) {
      print('Error saving to local recently played: $error');
    }
  }

  // Get local recently played songs
  static Future<List<Map<String, dynamic>>> getLocalRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentlyPlayedKey);

      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (error) {
      print('Error loading local recently played: $error');
    }

    return [];
  }

  // Sync local data with backend (for when app comes online)
  static Future<void> syncWithBackend() async {
    try {
      final localSongs = await getLocalRecentlyPlayed();

      if (localSongs.isNotEmpty) {
        // Prepare data for bulk sync
        final songsToSync = localSongs
            .map((song) => {
                  'songId': song['id']?.toString() ?? song['_id']?.toString(),
                  'playedAt':
                      song['playedAt'] ?? DateTime.now().toIso8601String(),
                })
            .where((song) => song['songId'] != null)
            .toList();

        if (songsToSync.isNotEmpty) {
          final response = await ApiService.syncRecentlyPlayed(songsToSync);

          if (response.statusCode == 401) {
            await _handleAuthError();
            return;
          }

          if (response.statusCode == 200) {
            print(
                'Successfully synced ${songsToSync.length} recently played songs');
          } else {
            print(
                'Failed to sync recently played songs: ${response.statusCode}');
          }
        }
      }
    } catch (error) {
      print('Error syncing recently played: $error');
    }
  }

  // Get recently played from backend
  static Future<List<Map<String, dynamic>>> getFromBackend(
      {int limit = 20}) async {
    try {
      final response = await ApiService.getRecentlyPlayed(limit: limit);
      print('Recently played response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        await _handleAuthError();
        return [];
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched recently played from backend: $data');

        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final songs = data['songs'] ?? data['recentlyPlayed'] ?? data['data'];
          if (songs is List) {
            return songs.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (error) {
      print('Error fetching recently played from backend: $error');
    }

    return [];
  }

  // Clear all recently played
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentlyPlayedKey);

      // You could also call a backend endpoint to clear server data
      // await ApiService.clearRecentlyPlayed();
    } catch (error) {
      print('Error clearing recently played: $error');
    }
  }

  static Future likeSong(String songId) async {
    try {
      final response = await ApiService.likeSong(songId);
      print('This response: ${response.statusCode}');
      if (response.statusCode == 401) {
        await _handleAuthError();
        return;
      }

      return response;
    } catch (error) {
      print('Errors liking song: $error');
    }
  }

  // static Future<void> _loadLikedStatus(String songId) async {
  //   try {
  //     final response = await ApiService.getLikedStatus(songId);
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         likedSong = json.decode(response.body)['liked'] ?? false;
  //       });
  //     }
  //   } catch (error) {
  //     print('Error loading liked status: $error');
  //   }
  // }
}
