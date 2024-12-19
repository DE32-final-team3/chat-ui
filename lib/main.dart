import 'package:flutter/material.dart';
import 'chat.dart'; // ChatScreen을 import

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      home: UserInputScreen(), // 초기 화면 설정
    );
  }
}

class UserInputScreen extends StatefulWidget {
  @override
  _UserInputScreenState createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final TextEditingController _user1Controller = TextEditingController();
  final TextEditingController _user2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Enter Users'),
          backgroundColor: const Color.fromARGB(255, 145, 115, 214)),
      backgroundColor: const Color.fromARGB(255, 193, 178, 227),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _user1Controller,
              decoration: InputDecoration(labelText: 'Sender (User 1)'),
            ),
            TextField(
              controller: _user2Controller,
              decoration: InputDecoration(labelText: 'Receiver (User 2)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final user1 = _user1Controller.text.trim();
                final user2 = _user2Controller.text.trim();
                if (user1.isNotEmpty && user2.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(user1: user1, user2: user2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter both users.')),
                  );
                }
              },
              child: Text('Start Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
