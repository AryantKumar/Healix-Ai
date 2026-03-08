# 🏥 Healix AI — Offline-First AI Health Assistant

> A beautifully crafted, **offline-first** AI health assistant built with **Flutter**. Healix AI lets users analyze symptoms via AI chat, find nearby hospitals, manage medications with native device alarms, store health records, and maintain a complete health timeline — all wrapped in a stunning glassmorphic dark UI.

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots & Screens](#-screens-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Data Models](#-data-models)
- [Services Layer](#-services-layer)
- [UI & Design System](#-ui--design-system)
- [API Integrations](#-api-integrations)
- [Permissions](#-permissions)
- [Getting Started](#-getting-started)
- [Configuration](#-configuration)
- [Disclaimer](#-disclaimer)

---

## ✨ Features

| Feature | Description |
|---|---|
| **AI Symptom Chat** | Describe symptoms and get AI-powered analysis via OpenRouter (Nemotron 3 Nano 30B). Falls back to an offline rule engine when there's no internet. |
| **Offline Rule Engine** | 20+ built-in symptom rules (fever, headache, chest pain, anxiety, etc.) provide instant guidance without any network connection. |
| **Hospital Finder** | Finds nearby hospitals using your current GPS location via the Overpass API (OpenStreetMap). |
| **Hospital Search** | Search for specialized hospitals by city name and keyword (e.g., "Bengaluru" + "Diabetic"). Uses geocoding to convert location text to coordinates. |
| **Medicine Reminders** | Add medications with dosage, frequency, and multiple reminder times. Each reminder creates both an in-app notification AND a native Android alarm in your device's Clock app. |
| **Health Records** | Store prescriptions, lab reports, X-rays, and medical notes. Attach files from your device. |
| **Health History Timeline** | Automatic timeline of every symptom check, medicine addition, and health event. |
| **Emergency Mode** | One-tap access to nearby hospitals with call and navigate actions + customizable emergency contacts. |
| **Editable User Profile** | View and edit your health profile (name, age, blood group, height, weight, allergies, chronic conditions). Your profile context is sent to the AI for personalized responses. |
| **Multi-Account Support** | Create profiles for yourself and family members (e.g., "Mom"). Switch between accounts instantly, logout to create new profiles, or delete accounts — all from the Profile screen. |
| **Dark Glassmorphic UI** | Premium dark theme with glass cards, gradient accents, smooth animations, and Google Fonts (Outfit + Inter). |

---

## 📱 Screens Overview

| # | Screen | File | Purpose |
|---|--------|------|---------|
| 1 | **Splash** | `views/splash/splash_screen.dart` | Animated launch screen with branding |
| 2 | **Welcome** | `views/onboarding/welcome_screen.dart` | Introduction and medical disclaimer |
| 3 | **Profile Type** | `views/onboarding/profile_type_screen.dart` | Choose "For Myself" or "For Someone Else" |
| 4 | **Bio Info** | `views/onboarding/bio_info_screen.dart` | Collect name, age, gender, blood group, height, weight |
| 5 | **Dashboard** | `views/dashboard/dashboard_screen.dart` | Home tab with health summary, quick actions grid, hospital search button, and emergency card |
| 6 | **AI Chat** | `views/chat/chat_screen.dart` | Conversational AI symptom analysis (online/offline) |
| 7 | **Hospital Finder** | `views/hospital/hospital_finder_screen.dart` | GPS-based nearby hospital list |
| 8 | **Hospital Search** | `views/hospital/hospital_search_screen.dart` | Text-based hospital search by location + specialty |
| 9 | **Medicine** | `views/medicine/medicine_screen.dart` | Add/manage medications and reminders |
| 10 | **Records** | `views/records/records_screen.dart` | Health document storage |
| 11 | **History** | `views/history/history_screen.dart` | Health event timeline |
| 12 | **Emergency** | `views/emergency/emergency_screen.dart` | Nearby hospitals + emergency contacts |
| 13 | **Profile** | `views/profile/profile_screen.dart` | View/edit profile + switch account, logout, delete account |

---

## 🏗 Architecture

Healix AI follows a **clean layered architecture** with clear separation of concerns:

```
┌───────────────────────────────────────┐
│              UI Layer                  │
│  (Screens / Widgets / Theme)          │
├───────────────────────────────────────┤
│           Services Layer              │
│  (Business Logic / API Calls / DB)    │
├───────────────────────────────────────┤
│            Models Layer               │
│  (Data Classes / JSON Serialization)  │
├───────────────────────────────────────┤
│         Core / Constants              │
│  (Theme / Typography / App Config)    │
└───────────────────────────────────────┘
```

### Design Principles

- **Offline-First**: Every feature has an offline fallback. AI chat uses a local `SymptomRuleEngine`. Hospital data falls back to mock data. All user data is stored locally in Hive.
- **Singleton Services**: All services (`DatabaseService`, `NotificationService`, `HospitalService`, `AiChatService`, `SymptomRuleEngine`) use the singleton pattern for consistent state.
- **Stateful Screens**: Each screen manages its own state via `StatefulWidget` — simple, predictable, and debuggable.
- **JSON Serialization**: All models implement `toJson()` and `fromJson()` factory constructors for Hive storage and API interop.

---

## 🛠 Tech Stack

### Core Framework
| Technology | Purpose |
|---|---|
| **Flutter 3.8+** | Cross-platform UI framework |
| **Dart** | Programming language |

### UI & Design
| Package | Purpose |
|---|---|
| `google_fonts` | Outfit (headlines) + Inter (body) typography |
| `flutter_animate` | Smooth fade, slide, and scale animations |
| `shimmer` | Loading shimmer effects |
| `percent_indicator` | Circular/linear progress indicators |
| `flutter_staggered_animations` | Staggered list animations |

### Data & Storage
| Package | Purpose |
|---|---|
| `hive` + `hive_flutter` | Lightweight NoSQL local database (8 boxes: user, records, medicine, chat, history, settings, emergency contacts, profiles) |
| `flutter_secure_storage` | Encrypted storage for sensitive data |

### Networking
| Package | Purpose |
|---|---|
| `http` | HTTP client for OpenRouter AI API and Overpass API |
| `connectivity_plus` | Real-time network status detection |

### Location & Maps
| Package | Purpose |
|---|---|
| `geolocator` | GPS location services |
| `geocoding` | Convert city names to lat/lng coordinates |
| `url_launcher` | Open Google Maps for navigation, make phone calls |

### Notifications & Alarms
| Package | Purpose |
|---|---|
| `flutter_local_notifications` | Scheduled local notification reminders |
| `timezone` | Timezone-aware scheduling |
| `android_intent_plus` | Create native Android Clock alarms |

### Utilities
| Package | Purpose |
|---|---|
| `uuid` | Generate unique IDs for all entities |
| `intl` | Date/time formatting |
| `file_picker` + `image_picker` | File and image selection for health records |
| `path_provider` + `path` | File system paths |
| `share_plus` | Share health data |
| `permission_handler` | Runtime permission requests |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, routes, theme
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # API keys, box names, enums, lists
│   └── theme/
│       ├── app_colors.dart            # Color palette + gradient definitions
│       ├── app_theme.dart             # Material ThemeData (dark theme)
│       └── app_typography.dart        # Text styles (Outfit + Inter)
├── models/
│   ├── user_profile.dart              # User health profile with BMI calc
│   ├── chat_message.dart              # Chat bubble data (user/AI, online/offline)
│   ├── medicine.dart                  # Medication with reminder times
│   ├── health_record.dart             # Document storage (prescriptions, reports)
│   ├── health_event.dart              # Timeline events (symptom, medicine, visit)
│   ├── hospital.dart                  # Hospital data (name, rating, coordinates)
│   └── emergency_contact.dart         # Emergency contact info
├── services/
│   ├── ai_chat_service.dart           # OpenRouter API integration
│   ├── symptom_rule_engine.dart       # Offline symptom analysis (20+ rules)
│   ├── hospital_service.dart          # Hospital search (Places/Overpass/Geocoding)
│   ├── database_service.dart          # Hive CRUD operations
│   └── notification_service.dart      # Local notifications + native alarms
├── views/
│   ├── splash/splash_screen.dart
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   ├── profile_type_screen.dart
│   │   └── bio_info_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── chat/chat_screen.dart
│   ├── hospital/
│   │   ├── hospital_finder_screen.dart
│   │   └── hospital_search_screen.dart
│   ├── medicine/medicine_screen.dart
│   ├── records/records_screen.dart
│   ├── history/history_screen.dart
│   ├── emergency/emergency_screen.dart
│   └── profile/profile_screen.dart
└── widgets/
    ├── glass_card.dart                # Reusable glassmorphic card widget
    ├── gradient_button.dart           # Gradient-styled button
    └── disclaimer_banner.dart         # Medical disclaimer banner
```

---

## 📊 Data Models

### `UserProfile`
Stores user health information. Computes BMI and BMI category automatically.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier |
| `name` | `String` | Full name |
| `age` | `int` | Age in years |
| `gender` | `String` | Male / Female / Other |
| `bloodGroup` | `String` | A+, B-, O+, etc. |
| `height` | `double` | Height in cm |
| `weight` | `double` | Weight in kg |
| `allergies` | `List<String>` | Known allergies |
| `chronicConditions` | `List<String>` | Ongoing conditions (e.g., Diabetes) |
| `isForSelf` | `bool` | Profile is for the user themselves |
| `bmi` | `double` | Computed: `weight / (height/100)²` |
| `bmiCategory` | `String` | Computed: Underweight / Normal / Overweight / Obese |

### `ChatMessage`
Represents a single chat bubble in the AI conversation.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID |
| `text` | `String` | Message content |
| `isUser` | `bool` | `true` = user, `false` = AI |
| `timestamp` | `DateTime` | When the message was sent |
| `isOffline` | `bool` | Whether the response came from offline engine |
| `isDisclaimer` | `bool` | Whether this is a disclaimer message |

### `Medicine`
Tracks a medication and its reminder schedule.

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID |
| `name` | `String` | Medication name |
| `dosage` | `String` | e.g., "500mg" |
| `frequency` | `String` | e.g., "Twice daily" |
| `reminderTimes` | `List<String>` | Times in "HH:mm" format |
| `isActive` | `bool` | Toggle reminders on/off |
| `startDate` / `endDate` | `DateTime` | Course duration |

### `Hospital`
Hospital data returned from API searches.

| Field | Type | Description |
|---|---|---|
| `name` | `String` | Hospital name |
| `address` | `String` | Street address |
| `distance` | `double` | Distance in km |
| `rating` | `double` | Star rating |
| `isOpen` | `bool` | Currently open |
| `latitude` / `longitude` | `double` | GPS coordinates |
| `phoneNumber` | `String?` | Contact number |

### `HealthRecord`
A stored medical document.

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Document title |
| `category` | `String` | Prescription, Lab Report, X-Ray, etc. |
| `filePath` | `String?` | Path to attached file |
| `notes` | `String?` | Optional notes |

### `HealthEvent`
A single entry in the health timeline.

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Event title |
| `type` | `HealthEventType` | symptom, prescription, visit, record, medicine |
| `date` | `DateTime` | When it occurred |
| `metadata` | `Map?` | Additional data |

---

## ⚙️ Services Layer

### 1. `AiChatService`
- **API**: OpenRouter (`https://openrouter.ai/api/v1/chat/completions`)
- **Model**: `nvidia/nemotron-3-nano-30b-a3b:free`
- **System Prompt**: Configured as a caring health assistant with strict rules (no diagnoses, always recommend doctors for serious symptoms)
- **Context**: Sends user profile data (age, gender, allergies, conditions) alongside messages for personalized responses
- **Chat History**: Maintains conversation context in-memory for multi-turn conversations

### 2. `SymptomRuleEngine`
- **Offline-only** symptom analyzer
- Contains **20+ symptom rules**: fever, headache, cough, sore throat, stomach pain, nausea, vomiting, diarrhea, chest pain, breathing difficulty, body pain, fatigue, dizziness, rash, cold, back pain, joint pain, eye pain, ear pain, anxiety, insomnia
- Each rule maps to: condition name, severity, description, advice list, and a "see doctor" flag
- Outputs formatted markdown with structured sections

### 3. `HospitalService`
- **Three-tier fallback**: Google Places API → Overpass API (OpenStreetMap) → Mock data
- **`getNearbyHospitals()`**: Uses current GPS coordinates
- **`searchHospitals()`**: Geocodes a city name (e.g., "Bengaluru") via the `geocoding` package, then searches around those coordinates with an optional keyword filter
- **Distance calculation**: Uses the Haversine formula for accurate distance in km
- **Keyword filtering**: Google Places uses the `keyword` URL parameter; Overpass results are filtered client-side by name/tags

### 4. `DatabaseService`
- **Engine**: Hive (lightweight NoSQL)
- **8 Boxes**: `user_box`, `records_box`, `medicine_box`, `chat_box`, `history_box`, `settings_box`, `emergency_contacts_box`, `profiles_box`
- **Multi-Account**: Supports multiple profiles — `getAllProfiles()`, `switchToProfile()`, `deleteProfile()`, with automatic migration of legacy single-profile data
- **Operations**: Full CRUD for all entity types
- **Initialization**: Called in `main()` before `runApp()`

### 5. `NotificationService`
- **Local Notifications**: Uses `flutter_local_notifications` with `zonedSchedule` for daily repeating medicine reminders at exact times
- **Native Alarms**: Uses `android_intent_plus` to fire `android.intent.action.SET_ALARM` with `SKIP_UI = true` — this silently creates a real alarm in the device's Clock app
- **Timezone Support**: All scheduling is timezone-aware via the `timezone` package

---

## 🎨 UI & Design System

### Color Palette
The app uses a **dark theme** with teal as the primary accent:

| Token | Hex | Usage |
|---|---|---|
| `background` | `#0A0E1A` | Main background |
| `surface` | `#111827` | Cards, bottom bar |
| `primary` | `#0D9488` | Teal accent |
| `accent` | `#6366F1` | Indigo secondary |
| `success` | `#22C55E` | Positive states |
| `warning` | `#F59E0B` | Caution states |
| `error` | `#EF4444` | Error states |
| `emergency` | `#DC2626` | SOS/emergency |

### Typography
- **Headlines**: Google Fonts **Outfit** (600-700 weight)
- **Body & Labels**: Google Fonts **Inter** (400-600 weight)
- 11 predefined text styles from `displayLarge` (32px) to `bodySmall` (12px)

### Glass Cards
The `GlassCard` widget provides a consistent glassmorphic container with:
- Semi-transparent background
- Subtle border
- Optional gradient overlay
- Rounded corners (20px)
- Tap callback support

### Animations
- `flutter_animate` powers all transitions
- Screens use staggered `fadeIn` + `slideY` / `slideX` for card entries
- Chat bubbles animate in with 300ms duration
- Hospital search results use delayed fade-in based on index

---

## 🌐 API Integrations

### 1. OpenRouter AI (Chat)
```
POST https://openrouter.ai/api/v1/chat/completions
Headers: Authorization: Bearer <API_KEY>
Model: nvidia/nemotron-3-nano-30b-a3b:free
```

### 2. Overpass API (Hospitals — Free, No Key)
```
POST https://overpass-api.de/api/interpreter
Body: Overpass QL query for amenity=hospital|clinic within radius
```

### 3. Google Places API (Hospitals — Optional)
```
GET https://maps.googleapis.com/maps/api/place/nearbysearch/json
Params: location, radius, type=hospital, keyword, key
```

### 4. Geocoding (Flutter Package)
```dart
locationFromAddress("Bengaluru") → [Location(lat, lng)]
```

---

## 🔐 Permissions

Declared in `android/app/src/main/AndroidManifest.xml`:

| Permission | Purpose |
|---|---|
| `ACCESS_FINE_LOCATION` | GPS for nearby hospitals |
| `ACCESS_COARSE_LOCATION` | Approximate location |
| `INTERNET` | API calls (AI, hospitals) |
| `CALL_PHONE` | Emergency phone calls |
| `POST_NOTIFICATIONS` | Medicine reminder notifications |
| `SCHEDULE_EXACT_ALARM` | Exact-time notifications |
| `SET_ALARM` | Create native device alarms |
| `VIBRATE` | Notification vibration |
| `RECEIVE_BOOT_COMPLETED` | Restore alarms after reboot |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Android Studio / VS Code with Flutter extension
- An Android device or emulator (API 21+)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/AryantKumar/Healix-Ai.git
cd Healix-Ai

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## ⚙️ Configuration

### OpenRouter API Key
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String openRouterApiKey = 'your-openrouter-api-key';
```

### Google Places API Key (Optional)
For premium hospital search results, set your Google Places key:
```dart
static const String placesApiKey = 'your-google-places-api-key';
```
> If not configured, the app automatically uses the free Overpass API instead.

---

## ⚠️ Disclaimer

> **Healix AI provides general health information only.** It is NOT a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.

---

## 📄 License

This project is for educational and personal use.

---

**Built with ❤️ using Flutter**
