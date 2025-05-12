import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'api_config.dart'; // Import the API config file

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
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get directions: ${response.body}');
    }
  }

  // Extract route geometry from response for drawing on map
  static List<LatLng> decodePolyline(Map<String, dynamic> response) {
    List<LatLng> points = [];

    try {
      final features = response['features'] as List;
      if (features.isEmpty) return points;

      final geometry = features[0]['geometry'];
      final coordinates = geometry['coordinates'] as List;

      for (final coord in coordinates) {
        // OpenRouteService returns [longitude, latitude]
        points.add(LatLng(coord[1], coord[0]));
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
  static Map<String, String> getDirectionsSummary(Map<String, dynamic> response) {
    try {
      final features = response['features'] as List;
      if (features.isEmpty) return {};

      final properties = features[0]['properties'];
      final segments = properties['segments'] as List;
      if (segments.isEmpty) return {};

      final summary = segments[0]['summary'];
      final double distance = summary['distance'];
      final double duration = summary['duration'];

      return {
        'distance': formatDistance(distance),
        'duration': formatDuration(duration),
      };
    } catch (e) {
      print('Error getting directions summary: $e');
      return {};
    }
  }

  // Extract steps from the response for turn-by-turn directions
  static List<Map<String, dynamic>> getDirectionsSteps(Map<String, dynamic> response) {
    final List<Map<String, dynamic>> directionsSteps = [];

    try {
      final features = response['features'] as List;
      if (features.isEmpty) return directionsSteps;

      final properties = features[0]['properties'];
      final segments = properties['segments'] as List;
      if (segments.isEmpty) return directionsSteps;

      for (final segment in segments) {
        final steps = segment['steps'] as List;
        for (final step in steps) {
          directionsSteps.add({
            'instruction': step['instruction'],
            'distance': formatDistance(step['distance']),
            'duration': formatDuration(step['duration']),
            'type': step['type'],
          });
        }
      }
    } catch (e) {
      print('Error getting directions steps: $e');
    }

    return directionsSteps;
  }
}