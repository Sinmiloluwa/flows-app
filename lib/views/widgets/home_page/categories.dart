import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesPage extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {
      "title": "Electronics",
      "image": "https://via.placeholder.com/150/0000FF/808080?Text=Electronics"
    },
    {
      "title": "Fashion",
      "image": "https://via.placeholder.com/150/FF0000/FFFFFF?Text=Fashion"
    },
    {
      "title": "Groceries",
      "image": "https://via.placeholder.com/150/00FF00/000000?Text=Groceries"
    },
    {
      "title": "Home",
      "image": "https://via.placeholder.com/150/FFFF00/000000?Text=Home"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 items per row
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return buildCategoryCard(categories[index]);
        },
      ),
    );
  }

  Widget buildCategoryCard(Map<String, String> category) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: category["image"]!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category["title"]!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
