import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'api_config.dart'; // Import the API config file
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class OpenRouteService {
  // Using API key from the config file
  static const String apiKey = ApiConfig.openRouteServiceApiKey;
  static const String baseUrl = 'https://api.openrouteservice.org/v2/directions/';

  // Method to get directions between two points
  static Future<Map<String, dynamic>> getDirections({
    required LatLng start,
    required LatLng end,
    String profile = 'driving-car', // Options: driving-car, foot-walking, cycling-regular
  }) async {
    final String url = '$baseUrl$profile';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': apiKey,
      },
      body: json.encode({
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ],
        'instructions': true,
        'format': 'geojson',
      }),
    );

    if (response.statusCode == 200) {
      // Explicitly decode the response body as UTF-8
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to get directions: ${response.body}');
    }
  }

  // Extract route geometry from response for drawing on map
  static List<LatLng> decodePolyline(Map<String, dynamic> response) {
    List<LatLng> points = [];

    try {
      final routes = response['routes'];
      if (routes == null || routes.isEmpty) {
        print('No routes found.');
        return points;
      }

      final encodedPolyline = routes[0]['geometry'];
      if (encodedPolyline == null || encodedPolyline is! String) {
        print('No encoded polyline found.');
        return points;
      }

      final decodedPoints = PolylinePoints().decodePolyline(encodedPolyline);

      for (final point in decodedPoints) {
        points.add(LatLng(point.latitude, point.longitude));
      }
    } catch (e) {
      print('Error decoding polyline: $e');
    }

    return points;
  }

  // Parse duration from response
  static String formatDuration(double seconds) {
    final int minutes = (seconds / 60).floor();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final int hours = (minutes / 60).floor();
      final int remainingMinutes = minutes % 60;
      return '$hours h $remainingMinutes min';
    }
  }

  // Parse distance from response
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final double km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Get directions summary from the response
  static Map<String, dynamic> getDirectionsSummary(Map<String, dynamic> response) {
    final summary = response['routes']?[0]?['summary'];
    if (summary == null) return {'distance': '', 'duration': ''};

    return {
      'distance': '${summary['distance']} m',
      'duration': '${summary['duration']} sec',
    };
  }

  // Extract steps from the response for turn-by-turn directions
  static List<Map<String, dynamic>> getDirectionsSteps(Map<String, dynamic> response) {
    final routes = response['routes'];
    if (routes == null || routes.isEmpty) return [];

    final segments = routes[0]['segments'];
    if (segments == null || segments.isEmpty) return [];

    List<Map<String, dynamic>> allSteps = [];
    for (final segment in segments) {
      final steps = segment['steps'] as List?;
      if (steps != null) {
        for (final step in steps) {
          allSteps.add({
            'instruction': step['instruction'] ?? '',
            'distance': '${step['distance']} m',
            'duration': '${step['duration']} sec',
          });
        }
      }
    }

    return allSteps;
  }
}