import 'package:flows/data/texts.dart';
import 'package:flows/views/widgets/genre_chip_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                style: kTextStyle.nameText.copyWith(// or different color, size, etc.
                  color: Colors.grey, // example override
                ), // style for "Hello,"
              ),
              TextSpan(
                text: 'John Smith',
                style: kTextStyle.nameText
              ),
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
                  const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.white
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white
                    ),
                      child: Icon(
                          Icons.mail_lock_outlined,
                          color: Colors.black
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Select Categories',
                style: kTextStyle.titleText,
              ),
            const SizedBox(height: 20),
            GenreChips()
          ],
        ),
      )
    );
  }
}
