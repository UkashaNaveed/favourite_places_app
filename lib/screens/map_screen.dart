import 'package:favourite_places_app/model/places_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlacesLocation(
      lattitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelected = true,
  });

  final PlacesLocation location;
  final bool isSelected;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final markerLocation = _pickedLocation ??
        LatLng(widget.location.lattitude, widget.location.longitude);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      appBar: AppBar(
        title: Text(widget.isSelected ? 'Choose Location' : 'Location'),
        actions: [
          if (widget.isSelected)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation ?? markerLocation);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                widget.location.lattitude,
                widget.location.longitude,
              ),
              initialZoom: 15.0,
              onTap: !widget.isSelected
                  ? null
                  : (tapPosition, point) {
                      setState(() {
                        _pickedLocation = point;
                      });
                    },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.favourite_places_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: markerLocation,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.place,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Floating bottom bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16191E).withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF262C36), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E222A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.navigation_outlined,
                            size: 16,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isSelected
                                    ? 'Pinpoint Location'
                                    : (widget.location.address.isNotEmpty
                                        ? widget.location.address
                                        : 'Saved Location'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFF3F4F6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${markerLocation.latitude.toStringAsFixed(4)}, ${markerLocation.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  color: Color(0xFF8B95A5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.isSelected) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(_pickedLocation ?? markerLocation);
                          },
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Confirm This Location'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
