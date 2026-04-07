# Verd — Drone Field Disease Detection

## Architecture

```
Flutter app  →  POST /scan (multipart image)  →  FastAPI backend
                                                       ↓
                                            Splits image into 8×8 grid
                                            Simulates disease per patch
                                            (seeded from image — reproducible)
                                                       ↓
Flutter renders heatmap  ←  Returns zone grid with disease + severity
```

---

## Backend setup

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

API is now at http://localhost:8000
Interactive docs at http://localhost:8000/docs

### Test it immediately
```bash
curl -X POST http://localhost:8000/scan \
  -F "image=@/path/to/any/farm/photo.jpg"
```

---

## Flutter setup

1. Copy these files into your project:
   - `flutter/Verd_service.dart`  →  `lib/services/Verd_service.dart`
   - `flutter/field_scan_screen.dart` →  `lib/screens/field_scan_screen.dart`

2. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     http: ^1.2.0
     image_picker: ^1.0.7
   ```

3. Update the API URL in `Verd_service.dart`:
   ```dart
   // Android emulator → localhost
   const String kApiBaseUrl = 'http://10.0.2.2:8000';

   // Real device on same WiFi
   const String kApiBaseUrl = 'http://192.168.x.x:8000';

   // Hugging Face Spaces (production)
   const String kApiBaseUrl = 'https://your-space.hf.space';
   ```

4. Navigate to the screen from anywhere in your app:
   ```dart
   Navigator.push(context, MaterialPageRoute(
     builder: (_) => const FieldScanScreen(),
   ));
   ```

5. Android: add to `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

---

## Deploy to Hugging Face Spaces

Rename `main.py` → `app.py` then push:
```bash
git init
git remote add origin https://huggingface.co/spaces/JibexBanks/Verd-drone
git add .
git commit -m "Verd drone scan API"
git push
```

The Space will auto-install `requirements.txt` and run uvicorn.
