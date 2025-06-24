import 'package:flutter/material.dart';

class GenreChips extends StatefulWidget {
  const GenreChips({super.key});

  @override
  State<GenreChips> createState() => _GenreChipsState();
}

class _GenreChipsState extends State<GenreChips> {
  final List<String> genres = ['All', 'Party', 'Blues', 'Sad', 'Hip Hop'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(
              right: index != genres.length - 1 ? 12.0 : 0, // 👈 padding only between
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFCEFF00) // Neon green
                      : const Color(0xFF1C1C1E), // Dark gray chip background
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  genres[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
