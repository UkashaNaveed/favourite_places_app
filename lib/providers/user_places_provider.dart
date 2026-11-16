import 'package:favourite_places_app/model/places_model.dart';
import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

Future<Database> _getrDatabase() async {
  final dbPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<PlacesModel>> {
  UserPlacesNotifier() : super([]);

  Future<void> loadPlaces() async {
    final db = await _getrDatabase();
    final data = await db.query('user_places');
    final places = data.map((row) {
      return PlacesModel(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image'] as String),
        location: PlacesLocation(
          lattitude: row['lat'] as double,
          longitude: row['lng'] as double,
          address: row['address'] as String,
        ),
      );
    }).toList();

    state = places;
  }

  Future<void> addPlaces(
    String label,
    File image,
    PlacesLocation location,
  ) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');

    final newPlace = PlacesModel(
      title: label,
      image: copiedImage,
      location: location,
    );

    final db = await _getrDatabase();

    await db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.lattitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }

  Future<void> deletePlace(String id) async {
    final db = await _getrDatabase();
    await db.delete('user_places', where: 'id = ?', whereArgs: [id]);
    state = state.where((p) => p.id != id).toList();
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<PlacesModel>>(
      (ref) => UserPlacesNotifier(),
    );
