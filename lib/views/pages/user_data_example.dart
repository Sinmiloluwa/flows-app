import 'package:flutter/material.dart';
import 'package:flows/services/api_service.dart';
import 'package:flows/services/session_service.dart';
import 'dart:convert';

class UserDataExample extends StatefulWidget {
  const UserDataExample({super.key});

  @override
  State<UserDataExample> createState() => _UserDataExampleState();
}

class _UserDataExampleState extends State<UserDataExample> {
  String? userToken;
  String? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndMakeApiCall();
  }

  Future<void> _loadTokenAndMakeApiCall() async {
    // Get the stored token
    final token = await SessionService.getToken();
    
    setState(() {
      userToken = token;
    });

    // Example: Make an authenticated API call using the token
    try {
      // This is an example of how you would use the ApiService for authenticated requests
      final response = await ApiService.get('/user/profile'); // Example endpoint
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userData = json.encode(responseData);
          isLoading = false;
        });
      } else {
        setState(() {
          userData = 'Failed to fetch user data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        userData = 'Error making API call: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Usage Example'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stored Token:',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                userToken ?? 'No token found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            Text(
              'API Response (using stored token):',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoading 
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        userData ?? 'No data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
