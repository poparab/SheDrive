import 'dart:convert';
import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8082);
  print('WebSocket Server running on ws://localhost:8082');

  final clients = <WebSocket>[];

  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      clients.add(socket);
      print('Client connected! Total clients: ${clients.length}');

      socket.listen((message) {
        print('Received: $message');
        for (final client in clients) {
          if (client != socket) {
            client.add(message);
          }
        }
      }, onDone: () {
        clients.remove(socket);
        print('Client disconnected! Total clients: ${clients.length}');
      }, onError: (e) {
        clients.remove(socket);
        print('Client error! Total clients: ${clients.length}');
      });
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('WebSocket connections only')
        ..close();
    }
  });
}
