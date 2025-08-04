import 'package:flows/services/api_service.dart';
import 'package:flows/services/session_service.dart';
import 'package:flows/views/pages/login_page.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';
import 'package:flows/views/widgets/music_controls_widget.dart';
import 'dart:convert';

class SongViewPage extends StatefulWidget {
  final String songId;

  const SongViewPage({super.key, required this.songId});

  @override
  State<SongViewPage> createState() => _SongViewPageState();
}

class _SongViewPageState extends State<SongViewPage> {
  final double kPageHorizontalPadding = 20.0;
  bool _isLoading = false;
  Map<String, dynamic>? _songData;

  // Helper getters for cleaner access to song data
  String get songTitle => _songData?['title'] ?? 'Song Title';
  String get artistName =>
      _songData?['artists']?[0]?['name'] ?? 'Unknown Artist';
  String get coverImage =>
      _songData?['cover_image_url'] ??
      'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop';

  bool get hasSongData => _songData != null;

  @override
  void initState() {
    super.initState();
    _viewSong();
  }

  Future<void> _viewSong() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Fetching song with ID: ${widget.songId}');
      final response = await ApiService.getSongById(widget.songId);

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body length: ${response.body.length}');
      print('Response body: ${response.body}');

      if (response.statusCode == 401) {
        // Handle unauthorized access - redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please log in again.')),
        );

        // Clear session and redirect to login
        await SessionService.clearSession();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
        return;
      } else if (response.statusCode == 404) {
        // Handle song not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song not found')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      } else if (response.statusCode != 200) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load song data: ${response.statusCode}')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check if response body is empty
      if (response.body.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No song data received from server')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Try to parse the JSON response
      try {
        final songData = json.decode(response.body);
        print('Parsed song data: $songData');

        setState(() {
          _songData = songData as Map<String, dynamic>;
          _isLoading = false;
        });
      } catch (jsonError) {
        print('JSON parsing error: $jsonError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid response format from server')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Network error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Changed from const to final as it's inside a class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        leadingWidth: kPageHorizontalPadding + 56.0,
        leading: Padding(
          padding: EdgeInsets.only(left: kPageHorizontalPadding),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(50)),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const ShimmerText(width: 120, height: 16)
                : Text(
                    songTitle,
                    style: kTextStyle.descriptionText.copyWith(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            SizedBox(height: 4),
            _isLoading
                ? const ShimmerText(width: 80, height: 14)
                : Text(
                    artistName,
                    style: kTextStyle.descriptionText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ],
        ),
        actions: [
          Padding(
            // Apply right padding to the actions widget
            padding: EdgeInsets.only(
                right:
                    kPageHorizontalPadding), // <<< FIX: Use kPageHorizontalPadding
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal:
                kPageHorizontalPadding), // <<< FIX: Use kPageHorizontalPadding for body too
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              width: double.infinity,
              height: 300, // Fixed height constraint
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isLoading
                  ? const ShimmerCard(
                      width: double.infinity,
                      height: 300,
                      borderRadius: 16,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        coverImage,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isLoading
                        ? const ShimmerText(width: 200, height: 24)
                        : Text(
                            songTitle,
                            style: kTextStyle.titleText,
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    _isLoading
                        ? const ShimmerText(width: 150, height: 18)
                        : Text(
                            artistName,
                            style: kTextStyle.descriptionText.copyWith(
                              color: Colors.grey,
                            ),
                          )
                  ],
                ),
                Icon(Icons.favorite)
              ],
            ),
            SizedBox(
              height: 20,
            ),
            MusicControls(),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    'Lyrics',
                    style: kTextStyle.titleText,
                  ),
                  Icon(Icons.keyboard_arrow_down_outlined)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
