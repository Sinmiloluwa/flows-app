import 'package:flutter/material.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                backgroundColor: Colors.greenAccent[400],
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildMenuItem(title: 'Email')
          ],
        ),
      ),
    );
  }
}

Widget _buildMenuItem({
  required String title,
  String? email,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 10),
    child: ListTile(
      // leading: Icon(
      //   icon,
      //   color: Colors.white,
      //   size: 24,
      // ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: SizedBox(
        width: 200,
        child: TextField(
          controller:
              TextEditingController(text: email ?? 'blvcksimons@gmail.com'),
          enabled: false,
          style: TextStyle(color: Colors.grey),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () {
        // Handle navigation or action here
      },
    ),
  );
}
