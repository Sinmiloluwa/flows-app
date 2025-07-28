import 'package:flutter/material.dart';

class MusicControls extends StatelessWidget {
  const MusicControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.greenAccent,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.greenAccent,
              overlayColor: Colors.green.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackShape: const RectangularSliderTrackShape(),
            ),
            child: Slider(
              value: 97, // seconds
              max: 261, // 4:21
              onChanged: (value) {},
            ),
          ),

          // Time indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("1:37", style: TextStyle(color: Colors.white)),
                Text("4:21", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.shuffle, color: Colors.white),
              Icon(Icons.skip_previous, size: 32, color: Colors.white),

              // Glowing Play Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow, size: 32, color: Colors.black),
              ),

              Icon(Icons.skip_next, size: 32, color: Colors.white),
              Icon(Icons.repeat, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
