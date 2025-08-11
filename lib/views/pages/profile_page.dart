import 'package:flows/views/pages/artists_page.dart';
import 'package:flutter/material.dart';
import 'package:flows/services/session_service.dart';
import 'package:flows/services/api_service.dart';
import 'package:flows/views/pages/login_page.dart';
import 'package:flows/data/texts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final sessionData = await SessionService.getSessionData();
    setState(() {
      userEmail = sessionData['email'];
      userId = sessionData['userId'];
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Confirm Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.green,
          ),
        ),
      );

      try {
        // Logout using API service (clears session)
        bool logoutSuccessful = await ApiService.logout();

        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

        if (logoutSuccessful) {
          // Navigate to login page and clear the entire navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Logout failed. Please try again.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } catch (error) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Network error during logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Profile',
          style: kTextStyle.titleText,
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.green,
                              child: Text(
                                userEmail?.substring(0, 1).toUpperCase() ?? 'U',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: kTextStyle.titleText.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    userEmail ?? 'No email',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Account Settings',
                    onTap: () {
                      // TODO: Navigate to account settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account Settings - Coming Soon'),
                          backgroundColor: Colors.grey[700],
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.music_note_outlined,
                    title: 'Music Preferences',
                    onTap: () {
                      // TODO: Navigate to music preferences
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Music Preferences - Coming Soon'),
                          backgroundColor: Colors.grey[700],
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Navigate to notifications settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notifications - Coming Soon'),
                          backgroundColor: Colors.grey[700],
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to help
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Help & Support - Coming Soon'),
                          backgroundColor: Colors.grey[700],
                        ),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.music_off_sharp,
                    title: 'Artist and more',
                    onTap: () {
                      // TODO: Navigate to artist and more
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtistsPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.grey[900],
      ),
    );
  }
}
