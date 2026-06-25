AI Customer Support - Flutter Demo

What this contains:

- Minimal Flutter app that sends a chat message to the backend `/chat` endpoint and dynamically renders UI based on `ui_type`.
- `HotelWidget` demonstrates a real, structured UI using `Card`, `ListView`, `Image`, and `Text`.

Quick start:

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Open the Flutter project folder `Frontend/flutter_app`.
3. Update `ApiService.baseUrl` in `lib/services/api_service.dart` to point to your backend (for Android emulator use `http://10.0.2.2:8000`).
4. Get packages:

```bash
cd Frontend/flutter_app
flutter pub get
```

5. Run the app:

```bash
flutter run
```

Notes:

- The app expects the backend `/chat` POST to return the same JSON schema as provided by the backend in this workspace.
- For testing on a real device, set `ApiService.baseUrl` to your machine's LAN IP (e.g. `http://192.168.1.10:8000`).

Files added:

- `lib/main.dart` Chat UI + dynamic renderer
- `lib/widgets/hotel_widget.dart` Hotel UI component
- `lib/services/api_service.dart` Simple HTTP client
- `lib/models/chat_response.dart` Response model
- `pubspec.yaml` Flutter manifest

Backend changes required/used:

- `/chat` should return `ui_type` values like `hotel_page`, `flight_page`, `tracking_page`, `refund_page`, `complaint_page`, `escalation_page` (these were aligned in backend tools).

If you want, I can:

- Add typed Dart models for hotels and other tools
- Add Provider/BLoC state management
- Dockerize the backend
- Implement streaming responses
