import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart'; // Ensure this path is correct
import 'package:flows/views/widgets/music_controls_widget.dart'; // Ensure this path is correct

class SongViewPage extends StatelessWidget {
  const SongViewPage({super.key});

  final double kPageHorizontalPadding = 20.0; // Changed from const to final as it's inside a class

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
            Text(
              'Song Title'.toUpperCase(),
              style: kTextStyle.descriptionText.copyWith(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Starboy Remix',
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
            padding: EdgeInsets.only(right: kPageHorizontalPadding), // <<< FIX: Use kPageHorizontalPadding
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
        padding: EdgeInsets.symmetric(horizontal: kPageHorizontalPadding), // <<< FIX: Use kPageHorizontalPadding for body too
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                  fit: BoxFit.cover,
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
                    Text(
                      'StarBoy Remix',
                      style: kTextStyle.titleText,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Jon Bellion',
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
            SizedBox(height: 40,),
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