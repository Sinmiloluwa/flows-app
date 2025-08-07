import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';
import 'package:flows/services/api_service.dart';
import 'package:flows/services/session_service.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flows/views/pages/song_view_page.dart';
import 'package:flows/views/pages/playlist_view_page.dart';
import 'package:flows/views/pages/login_page.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  List<dynamic> recentSearches = [];
  List<dynamic> trendingSearches = [];
  bool isSearching = false;
  bool isLoadingTrending = false;
  String currentQuery = '';

  // Tab controller for different search categories
  late TabController _tabController;
  List<String> searchTabs = ['All', 'Songs', 'Artists', 'Playlists'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: searchTabs.length, vsync: this);
    _loadTrendingSearches();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrendingSearches() async {
    setState(() {
      isLoadingTrending = true;
    });

    try {
      final response = await ApiService.get('/search/trending');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          trendingSearches = data['trending'] ?? data['data'] ?? [];
          isLoadingTrending = false;
        });
      } else {
        setState(() {
          isLoadingTrending = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoadingTrending = false;
      });
      print('Error loading trending searches: $error');
    }
  }

  Future<void> _loadRecentSearches() async {
    // In a real app, you'd load this from local storage
    // For now, we'll simulate some recent searches
    setState(() {
      recentSearches = [
        'Latest hits',
        'Pop music',
        'Hip hop',
        'Classical',
      ];
    });
  }


  Future<void> _performSearch(String query) async {
  if (query.isEmpty) {
    setState(() {
      searchResults = [];
      currentQuery = '';
      isSearching = false;
    });
    return;
  }

  setState(() {
    isSearching = true;
    currentQuery = query;
  });

  print('Searching for: $query');

  try {
    final response =
        await ApiService.get('/search?q=${Uri.encodeComponent(query)}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Search response: $data');

      List<dynamic> results = [];

      if (data is Map<String, dynamic>) {
        // Handle the specific API structure: {playlists: [], songs: [], artists: []}
        
        // Add playlists with type identifier
        if (data['playlists'] != null && data['playlists'] is List) {
          for (var playlist in data['playlists']) {
            if (playlist is Map<String, dynamic>) {
              playlist['type'] = 'playlist';
              // Map the API fields to expected field names
              playlist['title'] = playlist['name'];
              playlist['coverImage'] = playlist['image_url'];
              results.add(playlist);
            }
          }
        }

        // Add songs with type identifier
        if (data['songs'] != null && data['songs'] is List) {
          for (var song in data['songs']) {
            if (song is Map<String, dynamic>) {
              song['type'] = 'song';
              // Ensure coverImage field exists
              song['coverImage'] = song['cover_image_url'] ?? song['image_url'];
              results.add(song);
            }
          }
        }

        // Add artists with type identifier
        if (data['artists'] != null && data['artists'] is List) {
          for (var artist in data['artists']) {
            if (artist is Map<String, dynamic>) {
              artist['type'] = 'artist';
              artist['title'] = artist['name'];
              artist['coverImage'] = artist['image_url'] ?? artist['avatar_url'];
              results.add(artist);
            }
          }
        }
      } else if (data is List) {
        // Fallback: if response is directly a list
        results = data;
      }

      setState(() {
        searchResults = results;
        isSearching = false;
      });

      print('Processed ${results.length} search results');
      print('Results breakdown:');
      print('- Playlists: ${results.where((r) => r['type'] == 'playlist').length}');
      print('- Songs: ${results.where((r) => r['type'] == 'song').length}');
      print('- Artists: ${results.where((r) => r['type'] == 'artist').length}');

      // Add to recent searches
      if (!recentSearches.contains(query)) {
        setState(() {
          recentSearches.insert(0, query);
          if (recentSearches.length > 10) {
            recentSearches = recentSearches.take(10).toList();
          }
        });
      }
    } else if (response.statusCode == 401) {
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
        isSearching = false;
      });
      print('Search failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (error) {
    setState(() {
      isSearching = false;
    });
    print('Error performing search: $error');
  }
}

  void _onSearchChanged(String value) {
    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (value == _searchController.text) {
        _performSearch(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Search',
          style: kTextStyle.titleText.copyWith(fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: _buildSearchContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, playlists...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    if (currentQuery.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: Colors.lightGreenAccent[400],
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: searchTabs
            .map((tab) => Tab(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(tab),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSearchContent() {
    if (currentQuery.isEmpty) {
      return _buildEmptySearchState();
    }

    if (isSearching) {
      return _buildSearchLoading();
    }

    if (searchResults.isEmpty) {
      return _buildNoResults();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(),
        _buildFilteredResults('song'),
        _buildFilteredResults('artist'),
        _buildFilteredResults('playlist'),
      ],
    );
  }

  Widget _buildEmptySearchState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: kTextStyle.titleText.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            _buildRecentSearches(),
            const SizedBox(height: 30),
          ],
          Text(
            'Trending Now',
            style: kTextStyle.titleText.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          _buildTrendingSearches(),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentSearches.length,
        itemBuilder: (context, index) {
          final search = recentSearches[index];
          return Container(
            margin: EdgeInsets.only(
                right: index < recentSearches.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      search,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSearches() {
    if (isLoadingTrending) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(6, (index) {
          return ShimmerBox(
            width: 80 + (index * 20),
            height: 36,
            borderRadius: 20,
          );
        }),
      );
    }

    if (trendingSearches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Center(
              child: Icon(Icons.trending_up, size: 48, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No trending searches available',
                style: TextStyle(color: Colors.grey[600]),
            ),
            )
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: trendingSearches.map((trend) {
        String trendText = trend is String
            ? trend
            : trend['query'] ?? trend['title'] ?? 'Unknown';
        return GestureDetector(
          onTap: () {
            _searchController.text = trendText;
            _performSearch(trendText);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent[400]?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.lightGreenAccent[400]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up,
                    size: 16, color: Colors.lightGreenAccent[400]),
                const SizedBox(width: 8),
                Text(
                  trendText,
                  style: TextStyle(color: Colors.lightGreenAccent[400]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: kTextStyle.titleText.copyWith(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: kTextStyle.descriptionText.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        print("this is the result: ${searchResults[index]}");
        final result = searchResults[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildFilteredResults(String type) {
    final filteredResults = searchResults.where((result) {
      String resultType = result['type']?.toString().toLowerCase() ?? '';
      return resultType == type;
    }).toList();

    if (filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No ${type}s found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(dynamic result) {
    String title =
        result['title']?.toString() ?? result['name']?.toString() ?? 'Unknown';
    String subtitle =
        result['artist']?.toString() ?? result['description']?.toString() ?? '';
    String? image =
        result['coverImage']?.toString() ?? result['image']?.toString();
    String type = result['type']?.toString() ?? 'unknown';

    IconData leadingIcon;
    switch (type.toLowerCase()) {
      case 'song':
        leadingIcon = Icons.music_note;
        break;
      case 'artist':
        leadingIcon = Icons.person;
        break;
      case 'playlist':
        leadingIcon = Icons.playlist_play;
        break;
      default:
        leadingIcon = Icons.search;
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
            child: image != null
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: Icon(leadingIcon, color: Colors.white54, size: 24),
                    ),
                  )
                : Container(
                    color: Colors.grey[800],
                    child: Icon(leadingIcon, color: Colors.white54, size: 24),
                  ),
          ),
        ),
        title: Text(
          title,
          style: kTextStyle.titleText.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: kTextStyle.descriptionText.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[600],
        ),
        onTap: () {
          _onResultTap(result);
        },
      ),
    );
  }

  void _onResultTap(dynamic result) {
    String type = result['type']?.toString().toLowerCase() ?? '';
    String? id = result['id']?.toString() ?? result['_id']?.toString();

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    switch (type) {
      case 'song':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongViewPage(songId: id),
          ),
        );
        break;
      case 'playlist':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistViewPage(
              playlistId: id,
              playlistName: result['name']?.toString(),
            ),
          ),
        );
        break;
      case 'artist':
        // TODO: Navigate to artist page when implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artist page coming soon!'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This item type is not supported yet'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }
}
