import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocalBusNotifier extends Notifier<List<Map<String, dynamic>>> {
  WebSocketChannel? _channel;

  @override
  List<Map<String, dynamic>> build() {
    Future.microtask(() => _init());
    ref.onDispose(() {
      _channel?.sink.close();
    });
    return [];
  }

  void _init() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8082'));
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        state = [...state, data];
      }, onError: (e) {
        print('LocalBus stream error: $e');
      }, onDone: () {
        print('LocalBus disconnected');
      });
    } catch (e) {
      print('LocalBus connection error: $e');
    }
  }

  void broadcast(Map<String, dynamic> event) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(event));
    }
  }
}

final localBusProvider = NotifierProvider<LocalBusNotifier, List<Map<String, dynamic>>>(LocalBusNotifier.new);
