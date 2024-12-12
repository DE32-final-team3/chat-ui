import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String user1;
  final String user2;

  ChatScreen({required this.user1, required this.user2});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late WebSocketChannel _channel;
  List<Map<String, String>> _messages = [];
  String _statusMessage = 'Connecting to server...';

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://${dotenv.env['SERVER_IP']}:8000/ws/${widget.user1}/${widget.user2}'),
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

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text;
      _controller.clear();

      try {
        _channel.sink.add('$message');
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
      appBar: AppBar(
          title: Text('Chat: ${widget.user1} & ${widget.user2}'),
          backgroundColor: const Color.fromARGB(255, 145, 115, 214)),
      backgroundColor: const Color.fromARGB(255, 193, 178, 227),
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
                bool isUser = message['sender'] == widget.user1;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Text(
                              message['sender']![0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message']!,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
