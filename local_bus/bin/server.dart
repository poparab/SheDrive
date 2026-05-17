import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final List<WebSocketChannel> clients = [];

  var handler = webSocketHandler((WebSocketChannel webSocket, String? protocol) {
    clients.add(webSocket);
    print('Client connected. Total: ${clients.length}');
    
    webSocket.stream.listen((message) {
      print('Received: $message');
      // Broadcast to everyone else
      for (var client in clients) {
        if (client != webSocket) {
          client.sink.add(message);
        }
      }
    }, onDone: () {
      clients.remove(webSocket);
      print('Client disconnected. Total: ${clients.length}');
    });
  });

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('LocalBus running on ws://${server.address.host}:${server.port}');
}
