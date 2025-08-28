import 'package:cached_network_image/cached_network_image.dart';
import 'package:flows/data/texts.dart';
import 'package:flows/services/playlist_service.dart';
import 'package:flows/services/session_service.dart';
import 'package:flows/services/api_service.dart';
import 'package:flows/views/widgets/home_page/made_for_you.dart';
import 'package:flows/views/widgets/home_page/popular_songs.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flows/views/pages/song_view_page.dart';
import 'package:flows/views/pages/playlist_view_page.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  List<dynamic> categories = [];
  List<dynamic> popularSongs = [];
  List<dynamic> playlists = [];
  List<dynamic> madeForYouList = [];
  bool isLoadingCategories = false;
  bool isLoadingPopularSongs = false;
  bool isLoadingPlaylists = false;
  bool isLoadingMadeForYou = false;
  String? selectedCategoryId = 'all'; // Default selected category

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getCategories();
    getPopularSongs();
    loadPlaylists();
    loadMadeForYouPlaylists();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations here if needed
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final sessionData = await SessionService.getSessionData();
    setState(() {
      userEmail = sessionData['email'];
    });
  }

  Future<void> getCategories() async {
    setState(() {
      isLoadingCategories = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

    // Try to load cached categories first
    final cached = prefs.getString('categories_cache');
    if (cached != null) {
      final cachedList = json.decode(cached);
      setState(() {
        categories = cachedList;
        isLoadingCategories = false;
      });
    }

    final response = await ApiService.getCategories();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> categoriesList = [];

        if (data is List) {
          categoriesList = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('categories')) {
            categoriesList = data['categories'] ?? [];
          } else if (data.containsKey('data')) {
            categoriesList = data['data'] ?? [];
          } else {
            print(
                'Response structure not recognized, available keys: ${data.keys}');
            categoriesList = [];
          }
        }

        await prefs.setString('categories_cache', json.encode(categoriesList));

        setState(() {
          categories = categoriesList;
          isLoadingCategories = false;
        });
      } else if (response.statusCode == 503) {
        setState(() {
          isLoadingCategories = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.construction, color: Colors.orange, size: 64),
                      SizedBox(height: 24),
                      Text(
                        'We are working on a solution',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Kindly bear with us while we resolve this issue.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        setState(() {
          isLoadingCategories = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> getPopularSongs() async {
    print('Getting popular songs...');
    setState(() {
      isLoadingPopularSongs = true;
    });

    try {
      final response =
          await ApiService.get('/popularity/songs'); // Example endpoint
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> popularSongsList = [];

        if (data is List) {
          popularSongsList = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('categories')) {
            popularSongsList = data['categories'] ?? [];
          } else if (data.containsKey('data')) {
            popularSongsList = data['data'] ?? [];
          } else {
            print(
                'Response structure not recognized, available keys: ${data.keys}');
            popularSongsList = [];
          }
        }

        setState(() {
          popularSongs = popularSongsList;
          isLoadingPopularSongs = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoadingPopularSongs = false;
      });
      print('Error fetching popular songs: $error');
      return;
    }
    print('Fetching popular songs...');
  }

  Future<void> loadPlaylists() async {
    setState(() {
      isLoadingPlaylists = true;
    });

    try {
      final response = await ApiService.getPlaylists();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> playlistsList = [];

        if (data is List) {
          playlistsList = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('playlists')) {
            playlistsList = data['playlists'] ?? [];
          } else if (data.containsKey('data')) {
            playlistsList = data['data'] ?? [];
          } else {
            print(
                'Response structure not recognized, available keys: ${data.keys}');
            playlistsList = [];
          }
        }

        setState(() {
          playlists = playlistsList;
          isLoadingPlaylists = false;
        });
        print('Playlists loaded: $playlists');
      } else {
        setState(() {
          isLoadingPlaylists = false;
        });
        print('Failed to load playlists: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoadingPlaylists = false;
      });
      print('Error loading playlists: $error');
    }
  }

  void _onCategorySelected(dynamic category) {
    setState(() {
      selectedCategoryId = category['id'];
    });

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Selected: ${category['name']}'),
    //     backgroundColor: Colors.green,
    //     duration: Duration(seconds: 1),
    //   ),
    // );

    if (category['id'] != null && category['id'] != 'all') {
      _fetchSongsByCategory(category['id']);
    }
  }

  Future<void> _fetchSongsByCategory(String categoryId) async {
    setState(() {
      isLoadingPopularSongs = true;
    });
    try {
      final response = await ApiService.getSongsByCategory(categoryId);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data: $data');

        List<dynamic> popularSongsList = [];
        if (data is List) {
          // Filter out songs with empty artists list
          popularSongsList = data.where((song) {
            return song['artists'] != null &&
                song['artists'] is List &&
                song['artists'].isNotEmpty;
          }).toList();
        } else if (data is Map<String, dynamic>) {
          popularSongsList = (data as List).where((song) {
            return song['artists'] != null &&
                song['artists'] is List &&
                song['artists'].isNotEmpty;
          }).toList();
        }

        setState(() {
          popularSongs = popularSongsList;
          isLoadingPopularSongs = false;
        });
        print('Testing songs: $popularSongs');
      }
    } catch (error) {
      isLoadingPopularSongs = true;
      print('Error fetching songs by category: $error');
    }
  }

  Future<void> loadMadeForYouPlaylists() async {
    setState(() {
      isLoadingMadeForYou = true;
    });
    try {
      final madeForYouRaw = await PlaylistService.loadMadeForYou();

      final madeForYou = madeForYouRaw.where((item) {
        final artists = item['artists'];
        return artists != null && artists is List && artists.isNotEmpty;
      }).toList();
      print('madefor you: ${madeForYou[0]['artists'][0]['profilePicture']}');
      setState(() {
        isLoadingMadeForYou = false;
        madeForYouList = madeForYou;
      });
    } catch (error) {
      setState(() {
        isLoadingMadeForYou = false;
      });
      print('Error loading "Made For You" playlists: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: false,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Hello, ',
                  style: kTextStyle.nameText.copyWith(
                    // or different color, size, etc.
                    color: Colors.grey, // example override
                  ), // style for "Hello,"
                ),
                TextSpan(
                    text: userEmail?.split('@')[0] ?? 'User',
                    style: kTextStyle.nameText),
              ],
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
                        child: Icon(Icons.mail_lock_outlined,
                            color: Colors.black)),
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
                  'Select Categories',
                  style: kTextStyle.titleText,
                ),
                const SizedBox(height: 20),
                isLoadingCategories
                    ? SizedBox(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5, // Show 5 shimmer placeholders
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 12.0),
                              child: ShimmerBox(
                                width: 80 + (index * 20), // Varying widths
                                height: 35,
                                borderRadius: 25.0,
                              ),
                            );
                          },
                        ),
                      )
                    : categories.isEmpty
                        ? Text(
                            'No categories available',
                            style: TextStyle(color: Colors.grey),
                          )
                        : SizedBox(
                            height: 35, // Fixed height for horizontal scroll
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length +
                                  1, // +1 for "All" category
                              itemBuilder: (context, index) {
                                // Handle "All" category as first item
                                if (index == 0) {
                                  final isSelected =
                                      selectedCategoryId == 'all';
                                  return Container(
                                    margin: EdgeInsets.only(right: 12.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _onCategorySelected({
                                          'name': 'All',
                                          'id': 'all',
                                          'original': 'all',
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.lightGreenAccent[400]
                                              : const Color.fromARGB(
                                                  255, 58, 59, 58),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isSelected
                                                  ? Colors.lightGreenAccent
                                                      .withOpacity(0.3)
                                                  : Colors.grey
                                                      .withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'All',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.black
                                                  : Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Handle regular categories (adjust index by -1)
                                final category = categories[index - 1];

                                // Safely get category name with multiple fallbacks
                                String categoryName = 'Unknown Category';
                                String? categoryId;

                                try {
                                  if (category is Map<String, dynamic>) {
                                    categoryName =
                                        category['name']?.toString() ??
                                            category['title']?.toString() ??
                                            category['label']?.toString() ??
                                            'Unknown Category';
                                    categoryId = category['id']?.toString() ??
                                        category['_id']?.toString();
                                  } else if (category is String) {
                                    categoryName = category;
                                    categoryId = category;
                                  } else {
                                    categoryName = category.toString();
                                    categoryId = category.toString();
                                  }
                                } catch (e) {
                                  print(
                                      'Error processing category: $category, Error: $e');
                                  categoryName = 'Invalid Category';
                                }

                                final isSelected =
                                    selectedCategoryId == categoryId;

                                return Container(
                                  margin: EdgeInsets.only(right: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Handle category selection
                                      _onCategorySelected({
                                        'name': categoryName,
                                        'id': categoryId,
                                        'original': category,
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.lightGreenAccent[400]
                                            : const Color.fromARGB(
                                                255, 58, 59, 58),
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? Colors.lightGreenAccent
                                                    .withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          categoryName,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                const SizedBox(
                  height: 30,
                ),
                PopularSongsSection(isLoading: isLoadingPopularSongs, popularSongs: popularSongs),
                MadeForYouSection(isLoadingMadeForYou: isLoadingMadeForYou, madeForYouList: madeForYouList),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Playlist', style: kTextStyle.titleText),
                    Text(
                      'See all >>',
                      style: kTextStyle.descriptionText
                          .copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                isLoadingPlaylists
                    ? SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: 5, // Show 5 shimmer placeholders
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerCard(
                                    width: 150,
                                    height: 200,
                                    borderRadius: 16,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.grey[300],
                                        margin: const EdgeInsets.only(right: 4),
                                      ),
                                      ShimmerText(width: 100, height: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  ShimmerText(width: 80, height: 12),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : playlists.isEmpty
                        ? Center(
                            child: Text(
                              'No playlists available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: ListView.builder(
                              itemCount: playlists.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final playlist = playlists[index];

                                // Safely get playlist data
                                String playlistName = 'Unknown Playlist';
                                String? playlistImage;
                                String? playlistId;

                                try {
                                  if (playlist is Map<String, dynamic>) {
                                    playlistName =
                                        playlist['name']?.toString() ??
                                            playlist['title']?.toString() ??
                                            'Unknown Playlist';
                                    playlistImage =
                                        playlist['coverImage']?.toString() ??
                                            playlist['image']?.toString();
                                    playlistId = playlist['id']?.toString() ??
                                        playlist['_id']?.toString();
                                  } else if (playlist is String) {
                                    playlistName = playlist;
                                    playlistId = playlist;
                                  } else {
                                    playlistName = playlist.toString();
                                    playlistId = playlist.toString();
                                  }
                                } catch (e) {
                                  print(
                                      'Error processing playlist: $playlist, Error: $e');
                                  playlistName = 'Invalid Playlist';
                                }

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to playlist view page
                                    if (playlistId != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlaylistViewPage(
                                            playlistId: playlistId!,
                                            playlistName: playlistName,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Unable to open playlist'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 200,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: SizedBox(
                                            height: 200, // reduced image height
                                            width: double.infinity,
                                            child: Image.network(
                                              playlistImage ??
                                                  'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.grey,
                                                child: const Icon(
                                                    Icons.broken_image,
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
                                                  playlistName,
                                                  style: kTextStyle.titleText
                                                      .copyWith(
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ],
            ),
          ),
        ));
  }
}
