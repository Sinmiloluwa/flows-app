import 'package:flows/data/texts.dart';
import 'package:flows/views/pages/song_view_page.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Popular Songs Section ---
class PopularSongsSection extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> popularSongs;

  const PopularSongsSection({
    Key? key,
    required this.isLoading,
    required this.popularSongs,
  }) : super(key: key);

  String getSongId(dynamic song, int index) {
    return song['songId']?.toString() ??
        song['_id']?.toString() ??
        song['id']?.toString() ??
        index.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Songs', style: kTextStyle.titleText),
            if (popularSongs.length > 5)
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to "See all"
                  print('See all popular songs tapped');
                },
                child: Text(
                  'See all >>',
                  style: kTextStyle.descriptionText.copyWith(color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Loading State
        if (isLoading)
          const PopularSongsShimmer()

        // Empty State
        else if (popularSongs.isEmpty)
          const Center(
            child: Text(
              'No popular songs available',
              style: TextStyle(color: Colors.grey),
            ),
          )

        // Data State
        else
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: popularSongs.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final song = popularSongs[index];
                return PopularSongTile(
                  song: song,
                  songId: getSongId(song, index),
                );
              },
            ),
          ),
      ],
    );
  }
}

// --- Popular Songs Shimmer ---
class PopularSongsShimmer extends StatelessWidget {
  const PopularSongsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: 5,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerCard(width: 150, height: 200, borderRadius: 16),
                SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(width: 2, height: 20),
                    ShimmerText(width: 100, height: 16),
                  ],
                ),
                SizedBox(height: 5),
                ShimmerText(width: 80, height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Individual Song Tile ---
class PopularSongTile extends StatelessWidget {
  final dynamic song;
  final String songId;

  const PopularSongTile({
    Key? key,
    required this.song,
    required this.songId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = song['coverImage'] ??
        song['cover_image_url'] ??
        'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop';

    final title = song['title'] ?? 'Unknown';
    final artist =
        song['artist'] ?? (song['artists']?[0]?['name'] ?? 'Unknown Artist');

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SongViewPage(songId: songId),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Row(
            children: [
              Container(width: 2, height: 20, color: Colors.green),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: kTextStyle.titleText.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Artist
          Text(
            artist,
            style: kTextStyle.descriptionText.copyWith(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
