import 'package:flows/services/api_service.dart';
import 'package:flows/services/recently_played_service.dart';
import 'package:flows/views/pages/song_view_page.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';
import 'dart:convert';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<dynamic> recentlyPlayed = [];
  List<dynamic> recommendedSongList = [];
  bool isLoadingRecentlyPlayed = false;
  bool isLoadingRecommendedSongs = false;
  bool likedSong = false;

  @override
  void initState() {
    super.initState();
    // Load recently played songs
    loadRecentlyPlayed();
    _recommendedSongs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadRecentlyPlayed() async {
    setState(() {
      isLoadingRecentlyPlayed = true;
    });

    try {
      // Try to get from backend first
      final backendSongs =
          await RecentlyPlayedService.getFromBackend(limit: 10);

      if (backendSongs.isNotEmpty) {
        setState(() {
          recentlyPlayed = backendSongs;
          isLoadingRecentlyPlayed = false;
        });
      } else {
        // Fallback to local storage
        final localSongs = await RecentlyPlayedService.getLocalRecentlyPlayed();
        setState(() {
          recentlyPlayed = localSongs.take(10).toList();
          isLoadingRecentlyPlayed = false;
        });
      }

      RecentlyPlayedService.syncWithBackend();
    } catch (error) {
      setState(() {
        isLoadingRecentlyPlayed = false;
      });
      print('Error loading recently played: $error');
    }
  }

  Future<void> _recommendedSongs() async {
    try {
      setState(() {
        isLoadingRecommendedSongs = true;
      });
      final recommendedSongs = await ApiService.recommendedSongs();
      print('recommendedSongs.statusCode: ${recommendedSongs.statusCode}');

      if (recommendedSongs.statusCode == 200) {
        setState(() {
          recommendedSongList = json.decode(recommendedSongs.body);
          print('recommendedSongList: $recommendedSongList');
          isLoadingRecommendedSongs = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error loading recommended songs: $error');
    }
  }

  Future<void> likeSong(String songId) async {
    setState(() {
          likedSong = false;
        });
    try {
      final response = await RecentlyPlayedService.likeSong(songId);
      if (response.statusCode == 201) {
        setState(() {
          likedSong = true;
        });
      }
    } catch (error) {
      setState(() {
          likedSong = false;
        });
      print('Failed to like song: $error');
    }
  }

  // Future<void> _loadLikedStatus(String songId) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Text(
          'Explore',
          style: kTextStyle.nameText.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey.withOpacity(0.2)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.notifications_none_outlined,
                      color: Colors.white),
                  const SizedBox(width: 15),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white),
                      child:
                          Icon(Icons.mail_lock_outlined, color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recently Played',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 16),
              isLoadingRecentlyPlayed
                  ? SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 10),
                            child: const Column(
                              children: [
                                ShimmerCard(
                                    width: 150, height: 150, borderRadius: 8),
                                SizedBox(height: 8),
                                ShimmerText(width: 100, height: 16),
                                SizedBox(height: 4),
                                ShimmerText(width: 80, height: 12),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentlyPlayed.length, // Example item count
                        itemBuilder: (context, index) {
                          return Container(
                              height: 250,
                              width: 150,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: SizedBox(
                                      height: 200, // reduced image height
                                      width: double.infinity,
                                      child: Image.network(
                                        recentlyPlayed[index]['song']
                                                ['cover_image_url'] ??
                                            'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.grey,
                                          child: const Icon(Icons.broken_image,
                                              size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width:
                                              2, // thickness of the vertical line
                                          height:
                                              20, // height of the vertical line
                                          color: Colors.green,
                                          margin: const EdgeInsets.only(
                                              right:
                                                  4), // spacing between line and text
                                        ),
                                        Expanded(
                                          child: Text(
                                            recentlyPlayed[index]['song']
                                                    ['title'] ??
                                                'Unknown Song',
                                            style:
                                                kTextStyle.titleText.copyWith(
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    recentlyPlayed[index]['song']['artists'][0]
                                            ['name'] ??
                                        'Unknown Artist',
                                    style: kTextStyle.descriptionText.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ));
                        },
                      ),
                    ),
              SizedBox(
                height: 8,
              ),
              Text('Recommendations',
                  style: kTextStyle.titleText.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  )),
              SizedBox(
                height: 8,
              ),
              isLoadingRecommendedSongs
                  ? SizedBox(
                      height: 350,
                      width: 250,
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ShimmerCard(
                                width: 60,
                                height: 60,
                                borderRadius: 8,
                              ),
                              title: ShimmerText(width: 60),
                              subtitle: ShimmerText(width: 60),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      height: 350,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recommendedSongList.length,
                        itemBuilder: (context, index) {
                          String songTitle = recommendedSongList[index]
                                  ['title'] ??
                              'Unknown Song';
                          final artists = recommendedSongList[index]['artists']
                                  as List<dynamic>? ??
                              [];
                          final artistName = artists.isNotEmpty
                              ? (artists[0]['name'] ?? 'Unknown Artist')
                              : 'Unknown Artist';
                          String? songImage =
                              recommendedSongList[index]['cover_image_url'];
                          String songId =
                              recommendedSongList[index]['id']?.toString() ??
                                  '';

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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
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
                                style:
                                    kTextStyle.titleText.copyWith(fontSize: 16),
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
                                icon: likedSong
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        color: Colors.white54,
                                      ),
                                onPressed: () {
                                  likeSong(songId);
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SongViewPage(
                                      songId: songId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
              // Add your library content here
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
