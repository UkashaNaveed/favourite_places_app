import 'dart:convert';
import 'package:favourite_places_app/model/places_model.dart';
import 'package:favourite_places_app/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationImage extends StatefulWidget {
  const LocationImage({super.key, required this.onSelectLocation});

  final void Function(PlacesLocation location) onSelectLocation;

  @override
  State<LocationImage> createState() => _LocationImageState();
}

class _LocationImageState extends State<LocationImage> {
  PlacesLocation? _kLocationData;
  bool _isGettingLocation = false;

  Future<void> _savePlace(double lat, double long) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$long',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'FavouritePlacesApp/1.0 (ukashanaveed15foothballer@gmail.com)',
        },
      );

      String address = '$lat, $long';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['display_name'] != null) {
          address = data['display_name'] as String;
        }
      }

      setState(() {
        _kLocationData = PlacesLocation(
          lattitude: lat,
          longitude: long,
          address: address,
        );
      });
      widget.onSelectLocation(_kLocationData!);
    } catch (error) {
      // Fallback if reverse geocode fails (e.g. offline)
      setState(() {
        _kLocationData = PlacesLocation(
          lattitude: lat,
          longitude: long,
          address: 'Lat: ${lat.toStringAsFixed(4)}, Long: ${long.toStringAsFixed(4)}',
        );
      });
      widget.onSelectLocation(_kLocationData!);
    }
  }

  String get staticMapImageUrl {
    if (_kLocationData == null) {
      return '';
    }
    final lat = _kLocationData!.lattitude;
    final long = _kLocationData!.longitude;

    return 'https://maps.locationiq.com/v3/staticmap'
        '?key=pk.6ea41a362b06c1cf6318dc9909dcd7d0'
        '&center=$lat,$long'
        '&zoom=16'
        '&size=600x300'
        '&markers=icon:large-red-cutout|$lat,$long';
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      setState(() {
        _isGettingLocation = true;
      });

      final locationData = await location.getLocation();
      final lat = locationData.latitude;
      final long = locationData.longitude;

      if (lat != null && long != null) {
        await _savePlace(lat, long);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch location. Please try picking on map.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _selectOnMap() async {
    final defaultLocation = _kLocationData ??
        const PlacesLocation(
          lattitude: 37.422,
          longitude: -122.084,
          address: '',
        );

    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          location: defaultLocation,
          isSelected: true,
        ),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      await _savePlace(pickedLocation.latitude, pickedLocation.longitude);
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent;

    if (_isGettingLocation) {
      previewContent = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Fetching location...',
              style: TextStyle(
                color: Color(0xFF8B95A5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (_kLocationData != null) {
      previewContent = Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            staticMapImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF64748B),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_kLocationData!.lattitude.toStringAsFixed(4)}, ${_kLocationData!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Color(0xFF8B95A5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _kLocationData!.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      previewContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E3541), width: 1),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Location Selected',
              style: TextStyle(
                color: Color(0xFFF3F4F6),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Use GPS or pick a spot on the map',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF14171C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF262C36), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: previewContent,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _getLocation,
                icon: const Icon(Icons.my_location_rounded, size: 16),
                label: const Text('Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF262C36), width: 1),
                  backgroundColor: const Color(0xFF16191E),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _selectOnMap,
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('Choose on Map'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF262C36), width: 1),
                  backgroundColor: const Color(0xFF16191E),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
