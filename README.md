# Places

A minimalist, local-first mobile journal for documenting favorite places, travel memories, and geographic locations with photos and interactive maps.

Built with Flutter, Riverpod, SQLite, and OpenStreetMap.

---

## Demo

<div align="center">
  <video src="assets/demo.mp4" width="100%" controls="controls">
    Your browser does not support the video element.
  </video>
  <p><em>Walkthrough of adding a place, capturing a photo, locating via GPS/map, and offline browsing.</em></p>
</div>

> [!NOTE]
> To display your own walkthrough recording, add your video file to `assets/demo.mp4` or upload the `.mp4` file directly into a GitHub release/issue and update the source URL above.

---

## Features

- **Local-First Persistence**: Places, photos, and coordinates are stored locally on-device using SQLite (`sqflite`) and the system document directory, functioning seamlessly without an internet connection.
- **Geographic Tagging**:
  - **Live GPS Acquisition**: Automatically fetch device coordinates and resolve human-readable addresses using OpenStreetMap Nominatim reverse geocoding.
  - **Interactive Map Selection**: Tap anywhere on an OpenStreetMap interface to drop or adjust a location pin.
- **Photo Capture**: Capture memories directly with the device camera or select existing photos from the local photo gallery.
- **Interactive & Static Mapping**:
  - Live interactive maps powered by `flutter_map` and OpenStreetMap tile layers.
  - Cached static map snapshots powered by LocationIQ.
- **Curated UI & Typography**:
  - Restrained dark-slate color palette (`#0D0F12`) with high-contrast, accessible typography using Inter (`google_fonts`).
  - Gesture-driven interactions including pull-to-refresh and swipe-to-delete with undo capability.

---

## Architecture & Tech Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart SDK ^3.13) | Cross-platform UI toolkit |
| **State Management** | Flutter Riverpod | Reactive state and dependency injection |
| **Local Database** | SQLite (`sqflite`, `path`) | Structured local storage for place metadata |
| **Interactive Maps** | `flutter_map`, `latlong2` | Embedded OpenStreetMap rendering and gestures |
| **Location Services**| `location`, HTTP / Nominatim | GPS hardware access and reverse geocoding |
| **Camera & Media**   | `image_picker`, `path_provider` | Image capture, filesystem copying, and storage |
| **Typography**       | `google_fonts` (Inter) | Clean, scalable interface typography |

---

## Project Structure

```text
lib/
├── main.dart                  # Application entry point, global theme & providers
├── model/
│   └── places_model.dart      # Data models (PlacesModel, PlacesLocation)
├── providers/
│   └── user_places_provider.dart # Riverpod StateNotifier & SQLite integration
├── screens/
│   ├── places.dart            # Main places list screen
│   ├── add_places.dart        # Place creation form
│   ├── places_detail.dart     # Place hero & details viewer
│   └── map_screen.dart        # Fullscreen interactive map (picker & viewer)
└── widget/
    ├── places_list.dart       # List rendering, empty state & dismissible cards
    ├── pick_image.dart        # Camera & gallery image selector widget
    └── location_image.dart    # Map preview & GPS trigger widget
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13.0 or later)
- Android Studio or VS Code with Flutter extension
- An active Android emulator, iOS simulator, or connected physical device

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/favourite_places_app.git
   cd favourite_places_app
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

---

## Permissions & Device Capabilities

This application utilizes device hardware for camera and location features:

- **Camera**: Requires camera access to capture photographs of visited locations (`image_picker`).
- **Location**: Requires fine and coarse location permissions (`location`) to resolve current coordinates.

> [!TIP]
> When testing on an Android Emulator or iOS Simulator, ensure GPS location simulation is enabled in emulator settings to test current location detection.

> [!IMPORTANT]
> Reverse geocoding requests to OpenStreetMap Nominatim require a compliant `User-Agent` header, configured in `LocationImage` (`lib/widget/location_image.dart`). For high-volume production deployments, use a dedicated geocoding service key.
