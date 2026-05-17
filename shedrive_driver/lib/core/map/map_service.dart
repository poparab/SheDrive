import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class Poi {
  final String id;
  final String name;
  final LatLng location;
  final String type;

  Poi({required this.id, required this.name, required this.location, required this.type});

  factory Poi.fromJson(Map<String, dynamic> json) => Poi(
        id: json['id'],
        name: json['name'],
        location: LatLng(json['lat'], json['lng']),
        type: json['type'],
      );
}

class MapService {
  List<Poi> _pois = [];

  Future<void> loadPois() async {
    try {
      final String response = await rootBundle.loadString('assets/data/cairo_pois.json');
      final List<dynamic> data = json.decode(response);
      _pois = data.map((json) => Poi.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load POIs: $e');
    }
  }

  List<Poi> searchPois(String query) {
    if (query.isEmpty) return _pois;
    final lowercaseQuery = query.toLowerCase();
    return _pois.where((poi) => poi.name.toLowerCase().contains(lowercaseQuery)).toList();
  }

  List<LatLng> getRoute(LatLng start, LatLng end) {
    // Generates a curved multi-segment path that follows a plausible road pattern.
    // Not accurate to real roads but looks believable on a city-scale map.
    final rand = math.Random(start.hashCode ^ end.hashCode);
    final points = <LatLng>[start];
    const segments = 8;
    for (int i = 1; i < segments; i++) {
      final t = i / segments;
      final lat = start.latitude + (end.latitude - start.latitude) * t
          + (rand.nextDouble() - 0.5) * 0.008;
      final lng = start.longitude + (end.longitude - start.longitude) * t
          + (rand.nextDouble() - 0.5) * 0.008;
      points.add(LatLng(lat, lng));
    }
    points.add(end);
    return points;
  }
}

final mapServiceProvider = Provider<MapService>((ref) {
  return MapService();
});
