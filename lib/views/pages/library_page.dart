import 'package:cached_network_image/cached_network_image.dart';
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
  Set<String> likedSongIds = {};

  @override
  void initState() {
    super.initState();
    loadRecentlyPlayed();
    loadRecommendedSongs();
  }

  Future<void> loadRecentlyPlayed() async {
    setState(() => isLoadingRecentlyPlayed = true);
    try {
      final backendSongs = await RecentlyPlayedService.getFromBackend(limit: 10);
      final songs = backendSongs.isNotEmpty
          ? backendSongs
          : (await RecentlyPlayedService.getLocalRecentlyPlayed()).take(10).toList();

      setState(() {
        recentlyPlayed = songs;
        isLoadingRecentlyPlayed = false;
      });

      RecentlyPlayedService.syncWithBackend();
    } catch (e) {
      setState(() => isLoadingRecentlyPlayed = false);
      debugPrint('Error loading recently played: $e');
    }
  }

  Future<void> loadRecommendedSongs() async {
    setState(() => isLoadingRecommendedSongs = true);
    try {
      final res = await ApiService.recommendedSongs();
      if (res.statusCode == 200) {
        setState(() {
          recommendedSongList = json.decode(res.body);
          isLoadingRecommendedSongs = false;
        });
      } else {
        _showError('An error occurred');
      }
    } catch (e) {
      debugPrint('Error loading recommended songs: $e');
    } finally {
      setState(() => isLoadingRecommendedSongs = false);
    }
  }

  Future<void> likeSong(String songId) async {
    try {
      final res = await RecentlyPlayedService.likeSong(songId);
      if (res.statusCode == 201) {
        setState(() => likedSongIds.add(songId));
      }
    } catch (e) {
      setState(() => likedSongIds.remove(songId));
      debugPrint('Failed to like song: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Recently Played'),
            const SizedBox(height: 16),
            isLoadingRecentlyPlayed
                ? _recentlyPlayedShimmer()
                : _recentlyPlayedList(),

            const SizedBox(height: 16),
            _sectionTitle('Recommendations'),
            const SizedBox(height: 8),
            isLoadingRecommendedSongs
                ? _recommendationShimmer()
                : _recommendationList(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: Colors.black,
        title: Text('Explore', style: kTextStyle.nameText.copyWith(color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_none_outlined, color: Colors.white),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.mail_lock_outlined, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _sectionTitle(String title) => Text(
        title,
        style: kTextStyle.titleText.copyWith(color: Colors.white, fontSize: 24),
      );

  // === Shimmers ===
  Widget _recentlyPlayedShimmer() => SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (_, __) => Container(
            width: 150,
            margin: const EdgeInsets.only(right: 10),
            child: const Column(
              children: [
                ShimmerCard(width: 150, height: 150, borderRadius: 8),
                SizedBox(height: 8),
                ShimmerText(width: 100, height: 16),
                SizedBox(height: 4),
                ShimmerText(width: 80, height: 12),
              ],
            ),
          ),
        ),
      );

  Widget _recommendationShimmer() => ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: const ListTile(
            leading: ShimmerCard(width: 60, height: 60, borderRadius: 8),
            title: ShimmerText(width: 60),
            subtitle: ShimmerText(width: 60),
          ),
        ),
      );

  // === Lists ===
  Widget _recentlyPlayedList() => SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recentlyPlayed.length,
          itemBuilder: (_, i) {
            final song = recentlyPlayed[i]['song'];
            return _RecentlyPlayedCard(song: song);
          },
        ),
      );

  Widget _recommendationList() => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recommendedSongList.length,
        itemBuilder: (_, i) {
          final song = recommendedSongList[i];
          final songId = song['id']?.toString() ?? '';
          return _RecommendationTile(
            song: song,
            isLiked: likedSongIds.contains(songId),
            onLike: () => likeSong(songId),
          );
        },
      );
}

class _RecentlyPlayedCard extends StatelessWidget {
  final Map song;
  const _RecentlyPlayedCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: song['cover_image_url'] ??
                  'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ShimmerCard(width: double.infinity, height: 200, borderRadius: 16),
              errorWidget: (_, __, ___) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, size: 50)),
            ),
          ),
          const SizedBox(height: 8),
          Text(song['title'] ?? 'Unknown Song',
              style: kTextStyle.titleText.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(
            (song['artists']?[0]?['name']) ?? 'Unknown Artist',
            style: kTextStyle.descriptionText.copyWith(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final Map song;
  final bool isLiked;
  final VoidCallback onLike;

  const _RecommendationTile({
    required this.song,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final artists = (song['artists'] as List?) ?? [];
    final artistName = artists.isNotEmpty ? (artists[0]['name'] ?? 'Unknown Artist') : 'Unknown Artist';
    final songId = song['id']?.toString() ?? '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: song['cover_image_url'] ??
              'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.music_note, color: Colors.white54, size: 24),
          ),
        ),
      ),
      title: Text(song['title'] ?? 'Unknown Song',
          style: kTextStyle.titleText.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Text(artistName,
          style: kTextStyle.descriptionText.copyWith(fontSize: 14, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.green : Colors.white54),
        onPressed: onLike,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SongViewPage(songId: songId)),
      ),
    );
  }
}
