import 'package:flows/data/texts.dart';
import 'package:flows/services/session_service.dart';
import 'package:flows/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flows/views/pages/song_view_page.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  List<dynamic> categories = [];
  bool isLoadingCategories = false;
  String? selectedCategoryId = 'all'; // Default selected category

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getCategories();
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

        setState(() {
          categories = categoriesList;
          isLoadingCategories = false;
        });
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

  void _onCategorySelected(dynamic category) {
    setState(() {
      selectedCategoryId = category['id'];
    });

    // You can add logic here to:
    // 1. Filter songs by category
    // 2. Navigate to a category-specific page
    // 3. Update UI to show selected state
    // 4. Fetch songs for this category

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${category['name']}'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );

    // Example: Fetch songs for this category
    if (category['id'] != null && category['id'] != 'all') {
      // _fetchSongsByCategory(category['id']);
    }
  }

  // Optional: Method to fetch songs by category
  // Future<void> _fetchSongsByCategory(String categoryId) async {
  //   try {
  //     final response = await ApiService.getSongsByCategory(categoryId);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       // Handle the songs data
  //       print('Songs for category: $data');
  //     }
  //   } catch (error) {
  //     print('Error fetching songs by category: $error');
  //   }
  // }

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
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.green,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Popular Songs', style: kTextStyle.titleText),
                    GestureDetector(
                      onTap: () {
                        // Navigate to popular songs page or show all popular songs
                        print('See all popular songs tapped');
                        // You can add navigation logic here
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => PopularSongsPage()));
                      },
                      child: Text(
                        'See all >>',
                        style: kTextStyle.descriptionText
                            .copyWith(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 150,
                        height: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SongViewPage()),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?q=80&w=1619&auto=format&fit=crop',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey,
                                      child: const Icon(Icons.broken_image,
                                          size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: Colors.green,
                                  margin: const EdgeInsets.only(right: 4),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SongViewPage()),
                                    );
                                  },
                                  child: Text(
                                    'Oblivious $index',
                                    style: kTextStyle.titleText
                                        .copyWith(fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Jon Bellion $index',
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
                    },
                  ),
                ),
                // SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('New Collection', style: kTextStyle.titleText),
                    // Text(
                    //   'See all >>',
                    //   style:
                    //   kTextStyle.descriptionText.copyWith(color: Colors.grey),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 300,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 140, // reduced image height
                                  width: double.infinity,
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1645441656150-e0a15f7c918d?q=80&w=2968&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                                      width:
                                          2, // thickness of the vertical line
                                      height: 20, // height of the vertical line
                                      color: Colors.green,
                                      margin: const EdgeInsets.only(
                                          right:
                                              4), // spacing between line and text
                                    ),
                                    Text(
                                      'Oblivious $index',
                                      style: kTextStyle.titleText.copyWith(
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Jon Bellion $index',
                                  style: kTextStyle.descriptionText.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
                SizedBox(
                  height: 30,
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
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 150,
                        height: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 200, // reduced image height
                                width: double.infinity,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1603568705176-f8b40039b087?q=80&w=1015&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
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
                                  Text(
                                    'Oblivious $index',
                                    style: kTextStyle.titleText.copyWith(
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Jon Bellion $index',
                                style: kTextStyle.descriptionText.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
