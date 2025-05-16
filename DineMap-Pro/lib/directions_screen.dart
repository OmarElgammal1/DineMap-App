import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'utils/openroute_service.dart';

class DirectionsScreen extends StatefulWidget {
  final LatLng start;
  final LatLng end;

  const DirectionsScreen({required this.start, required this.end, super.key});

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _steps = [];
  String _distance = '';
  String _duration = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDirections();
  }

  Future<void> _loadDirections() async {
    try {
      final response = await OpenRouteService.getDirections(
        start: widget.start,
        end: widget.end,
      );

      setState(() {
        _routePoints = OpenRouteService.decodePolyline(response);
        _steps = OpenRouteService.getDirectionsSteps(response);
        final summary = OpenRouteService.getDirectionsSummary(response);
        _distance = summary['distance'] ?? '';
        _duration = summary['duration'] ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Directions')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: widget.start, initialZoom: 13.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(points: _routePoints, strokeWidth: 4.0, color: Colors.blue),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: widget.start,
                      child: const Icon(Icons.location_on, color: Colors.green),
                    ),
                    Marker(
                      width: 40,
                      height: 40,
                      point: widget.end,
                      child: const Icon(Icons.flag, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Distance: $_distance, Duration: $_duration'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return ListTile(
                  leading: const Icon(Icons.directions),
                  title: Text(step['instruction']),
                  subtitle: Text('${step['distance']} • ${step['duration']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
