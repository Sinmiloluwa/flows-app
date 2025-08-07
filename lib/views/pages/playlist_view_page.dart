import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';
import 'package:flows/services/api_service.dart';
import 'package:flows/services/session_service.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flows/views/pages/login_page.dart';
import 'dart:convert';

class PlaylistViewPage extends StatefulWidget {
  final String playlistId;
  final String? playlistName;

  const PlaylistViewPage({
    super.key,
    required this.playlistId,
    this.playlistName,
  });

  @override
  State<PlaylistViewPage> createState() => _PlaylistViewPageState();
}

class _PlaylistViewPageState extends State<PlaylistViewPage> {
  Map<String, dynamic>? playlistData;
  List<dynamic> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistData();
  }

  Future<void> _loadPlaylistData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.get('/playlists/${widget.playlistId}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          playlistData = data;
          songs = data['songs'] ?? [];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Handle unauthorized access
        await SessionService.clearSession();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load playlist: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error loading playlist: $error');
    }
  }

  String get playlistTitle {
    if (playlistData != null) {
      return playlistData!['name']?.toString() ??
          playlistData!['title']?.toString() ??
          widget.playlistName ??
          'Unknown Playlist';
    }
    return widget.playlistName ?? 'Playlist';
  }

  String get playlistDescription {
    if (playlistData != null) {
      return playlistData!['description']?.toString() ??
          '${songs.length} songs';
    }
    return 'Loading...';
  }

  String? get playlistImage {
    if (playlistData != null) {
      return playlistData!['coverImage']?.toString() ??
          playlistData!['image']?.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Playlist',
          style: kTextStyle.titleText.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildShimmerLoading()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlaylistHeader(),
                  const SizedBox(height: 30),
                  _buildSongsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header shimmer
            ShimmerCard(width: 200, height: 200, borderRadius: 16),
            const SizedBox(height: 16),
            ShimmerText(width: 150, height: 24),
            const SizedBox(height: 8),
            ShimmerText(width: 100, height: 16),
            const SizedBox(height: 30),

            // Songs list shimmer
            ...List.generate(
                8,
                (index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          ShimmerCard(width: 60, height: 60, borderRadius: 8),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerText(width: double.infinity, height: 16),
                                const SizedBox(height: 4),
                                ShimmerText(width: 120, height: 12),
                              ],
                            ),
                          ),
                          ShimmerCard(width: 24, height: 24, borderRadius: 12),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.network(
                  playlistImage ??
                      'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      size: 80,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            playlistTitle,
            style: kTextStyle.titleText.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            playlistDescription,
            style: kTextStyle.descriptionText.copyWith(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.play_arrow,
                label: 'Play',
                onTap: () {
                  // TODO: Implement play functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Play functionality coming soon!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.shuffle,
                label: 'Shuffle',
                onTap: () {
                  // TODO: Implement shuffle functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shuffle functionality coming soon!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.lightGreenAccent[400],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList() {
    print(songs);
    if (songs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.music_off,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'No songs in this playlist',
                style: kTextStyle.titleText.copyWith(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some songs to get started',
                style: kTextStyle.descriptionText.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Songs (${songs.length})',
            style: kTextStyle.titleText.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              String songTitle = 'Unknown Song';
              String artistName = 'Unknown Artist';
              String? songImage;

              try {
                if (song is Map<String, dynamic>) {
                  songTitle = song['title']?.toString() ??
                      song['name']?.toString() ??
                      'Unknown Song';
                  artistName = song['artist']['name']?.toString() ??
                      song['artistName']?.toString() ??
                      'Unknown Artist';
                  songImage = song['coverImage']?.toString() ??
                      song['image']?.toString();
                }
              } catch (e) {
                print('Error processing song: $song, Error: $e');
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        songImage ??
                            'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    songTitle,
                    style: kTextStyle.titleText.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    artistName,
                    style: kTextStyle.descriptionText.copyWith(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      // TODO: Show song options menu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Song options coming soon!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    // TODO: Play this specific song
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Playing: $songTitle'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
