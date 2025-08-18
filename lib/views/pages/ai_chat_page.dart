import 'package:flows/views/widgets/loading_dots.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Add this
  List<Map<String, String>> messages = [];
  bool isAssistantLoading = false;

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({'role': 'user', 'content': text});
      isAssistantLoading = true;
    });
    _scrollToBottom();

    // Replace with your OpenAI API key
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'),
      headers: {
        'X-goog-api-key': '$apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': text}
            ]
          }
        ],
      }),
    );

    final data = json.decode(response.body);
    print('AI response: ${data.toString()}');
    String aiReply = 'No response';
    if (data['candidates'] != null &&
        data['candidates'].isNotEmpty &&
        data['candidates'][0]['content'] != null &&
        data['candidates'][0]['content']['parts'] != null &&
        data['candidates'][0]['content']['parts'].isNotEmpty) {
      aiReply =
          data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
    }

    setState(() {
      messages.add({'role': 'assistant', 'content': aiReply});
      isAssistantLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Music Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((msg) {
                final isAssistant = msg['role'] == 'assistant';
                return Align(
                  alignment: isAssistant
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAssistant ? Colors.green[700] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isAssistant
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['content'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          msg['role'] ?? '',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (isAssistantLoading)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const LoadingDots(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'How can I help you today...',
                      hintStyle: TextStyle(color: Colors.white54),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.green,
                            width: 2), // Green border on focus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey, width: 1), // Default border
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
