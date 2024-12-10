import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketConsumerWidget extends StatefulWidget {
  final String url;

  WebSocketConsumerWidget({required this.url});

  @override
  _WebSocketConsumerWidgetState createState() =>
      _WebSocketConsumerWidgetState();
}

class _WebSocketConsumerWidgetState extends State<WebSocketConsumerWidget> {
  late WebSocketChannel _channel;
  String _message = "";

  @override
  void initState() {
    super.initState();
    // WebSocket 서버에 연결
    _channel = WebSocketChannel.connect(Uri.parse(widget.url));

    // WebSocket에서 메시지 수신
    _channel.stream.listen((message) {
      setState(() {
        _message = message; // 수신한 메시지를 화면에 표시
      });
    });
  }

  @override
  void dispose() {
    // WebSocket 연결 종료
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebSocket Consumer")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Received Message: $_message", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // WebSocket 서버에 메시지 전송
                _channel.sink.add("Hello Server!");
              },
              child: Text("Send Message"),
            ),
          ],
        ),
      ),
    );
  }
}
