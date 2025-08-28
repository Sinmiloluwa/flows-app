import 'package:flows/data/texts.dart';
import 'package:flows/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class MadeForYouSection extends StatelessWidget {
  const MadeForYouSection({
    Key? key,
    required this.isLoadingMadeForYou,
    required this.madeForYouList,
  }) : super(key: key);

  final bool isLoadingMadeForYou;
  final List<dynamic> madeForYouList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Made for you', style: kTextStyle.titleText)],
        ),
        SizedBox(
          height: 20,
        ),
        isLoadingMadeForYou
            ? SizedBox(
                height: 100,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: ShimmerBox(
                      width: 200,
                      height: 50,
                      borderRadius: 16,
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 200,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: madeForYouList.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = madeForYouList[index];
                    final artists = item['artists'] as List<dynamic>? ?? [];
                    final firstArtist = artists.isNotEmpty
                        ? artists[0] as Map<String, dynamic>?
                        : null;
                    final artistImage = firstArtist?['profilePicture'] ??
                        'https://images.unsplash.com/photo-1645441656150-e0a15f7c918d?q=80&w=2968&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
                    final artistName = firstArtist?['name'] ?? 'Unknown Artist';
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Image
                              Image.network(
                                artistImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey,
                                  child:
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),

                              // Gradient Overlay for better text readability
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),

                              // Text Content Positioned at Bottom
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title with green accent line
                                    Row(
                                      children: [
                                        Container(
                                          width:
                                              2, // thickness of the vertical line
                                          height:
                                              20, // height of the vertical line
                                          color: Colors.green,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                        ),
                                        Expanded(
                                          child: Text(
                                            artistName,
                                            style:
                                                kTextStyle.titleText.copyWith(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Artist/Subtitle
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
