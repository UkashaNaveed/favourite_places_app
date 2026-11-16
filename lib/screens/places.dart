import 'package:favourite_places_app/providers/user_places_provider.dart';
import 'package:favourite_places_app/screens/add_places.dart';
import 'package:favourite_places_app/widget/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Places extends ConsumerStatefulWidget {
  const Places({super.key});

  @override
  ConsumerState<Places> createState() {
    return _PlacesState();
  }
}

class _PlacesState extends ConsumerState<Places> {
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  Future<void> _refreshPlaces() async {
    await ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(userPlacesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const Text('Places'),
            if (places.isNotEmpty) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E222A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF262C36),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${places.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B95A5),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF16191E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF262C36), width: 1),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddPlaces()),
                  );
                },
                icon: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFFF3F4F6),
                ),
                tooltip: 'Add Place',
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF3B82F6),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPlaces,
            color: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFF16191E),
            child: PlacesList(places: places),
          );
        },
      ),
    );
  }
}
