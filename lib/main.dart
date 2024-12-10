import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late WebSocketChannel _channel;
  List<Map<String, String>> _messages = [];
  String _statusMessage = 'Connecting to server...';

  final String user1 = "t2"; // 현재 사용자
  final String user2 = "t1"; // 상대 사용자
  final String serverUrl = "http://localhost:8000"; // 서버 URL

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/$user1/$user2'),
    );

    _channel.stream.listen(
      (message) {
        setState(() {
          final decodedMessage = message.split(': ');
          _messages.add({
            "sender": decodedMessage[0],
            "message": decodedMessage[1],
          });
        });
      },
      onDone: () {
        setState(() {
          _statusMessage = 'Disconnected from the server';
        });
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'Error: $error';
        });
      },
    );

    setState(() {
      _statusMessage = 'Connected to server';
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text;
      setState(() {
        _messages.add({"sender": "Me", "message": message});
      });
      _controller.clear();

      try {
        await http.post(
          Uri.parse(
              '$serverUrl/send/t1-t2?sender=$user1&receiver=$user2&message=$message'),
          headers: {"Content-Type": "application/json"},
        );
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Chat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_statusMessage,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(
                    "${message['sender']}: ${message['message']}",
                    style: TextStyle(
                      color: message['sender'] == "Me"
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
