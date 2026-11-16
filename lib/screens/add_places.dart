import 'package:favourite_places_app/model/places_model.dart';
import 'package:favourite_places_app/providers/user_places_provider.dart';
import 'package:favourite_places_app/widget/location_image.dart';
import 'package:favourite_places_app/widget/pick_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';

class AddPlaces extends ConsumerStatefulWidget {
  const AddPlaces({super.key});

  @override
  ConsumerState<AddPlaces> createState() => _AddPlacesState();
}

class _AddPlacesState extends ConsumerState<AddPlaces> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlacesLocation? _selectedLocation;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a place title')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo for this place')),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or attach a location')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(userPlacesProvider.notifier)
          .addPlaces(title, _selectedImage!, _selectedLocation!);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save place: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F12),
      appBar: AppBar(
        title: const Text('New Place'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildSectionLabel('PLACE NAME'),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  color: Color(0xFFF3F4F6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. Quiet Cove, Sunset Lookout',
                  prefixIcon: Icon(
                    Icons.drive_file_rename_outline_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Image Picker
              _buildSectionLabel('PHOTO'),
              PickImage(
                onPickImage: (image) {
                  setState(() {
                    _selectedImage = image;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Location Selector
              _buildSectionLabel('LOCATION'),
              LocationImage(
                onSelectLocation: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Save CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_isSaving ? 'Saving...' : 'Save Place'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
