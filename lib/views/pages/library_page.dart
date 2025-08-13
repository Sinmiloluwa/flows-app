import 'package:flows/services/recently_played_service.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<dynamic> recentlyPlayed = [];
  bool isLoadingRecentlyPlayed = false;

  @override
  void initState() {
    super.initState();
    // Load recently played songs
    loadRecentlyPlayed();
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
          print(backendSongs);

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
                                  ShimmerCard(width: 150, height: 150, borderRadius: 8),
                                  SizedBox(height: 8),
                                  ShimmerText(width: 100, height: 16),
                                  SizedBox(height: 4),
                                  ShimmerText(width: 80, height: 12),
                                ],
                              ),
                            );
                          },
                        ),
                      ) :
              SizedBox(
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
                                  recentlyPlayed[index]['song']['cover_image_url'] ?? 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
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
                                    width: 2, // thickness of the vertical line
                                    height: 20, // height of the vertical line
                                    color: Colors.green,
                                    margin: const EdgeInsets.only(
                                        right:
                                            4), // spacing between line and text
                                  ),
                                  Expanded(
                                    child: Text(
                                      recentlyPlayed[index]['song']['title'] ?? 'Unknown Song',
                                      style: kTextStyle.titleText.copyWith(
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
                              recentlyPlayed[index]['song']['artists'][0]['name'] ?? 'Unknown Artist',
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  String songTitle = 'Unknown Song';
                  String artistName = 'Unknown Artist';
                  String? songImage;

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
                            errorBuilder: (context, error, stackTrace) =>
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
                          Icons.favorite_border,
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
              // Add your library content here
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
