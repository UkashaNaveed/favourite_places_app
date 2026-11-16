import 'package:uuid/uuid.dart';

import 'dart:io';

final uuid = Uuid();

class PlacesLocation {
  const PlacesLocation({
    required this.lattitude,
    required this.longitude,
    required this.address,
  });
  final double lattitude;
  final double longitude;
  final String address;
}

class PlacesModel {
  PlacesModel({
    required this.title,
    required this.image,
    required this.location,
    String? id,
  }) : id = id ?? uuid.v4();

  final String title;
  final String id;
  final File image;
  final PlacesLocation location;
}
