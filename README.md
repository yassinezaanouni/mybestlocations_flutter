# Location Bookmarking & Management App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Maps](https://img.shields.io/badge/Google_Maps-4285F4?style=flat&logo=google-maps&logoColor=white)

A Flutter-based location management application developed during my Engineering degree at ISSAT. This app enables users to bookmark and categorize places on an interactive map with comprehensive location management features.

## 📝 License

This project is a university project reshared for educational purposes. Feel free to use it as reference for your own projects.

[Previous sections remain the same until Features]

## 📱 Features

- 📍 **Real-time Location Tracking**: Always know your current position
- 🔖 **Custom Location Bookmarking**: Save locations with:
  - 📝 Custom name
  - 📞 Phone number
  - 🏷️ Category selection
- 🎯 **Category-based Markers**: Distinctive icons for different categories
  - 🏠 Home
  - 💼 Work
  - 🍽️ Restaurant
  - 🛒 Shopping
  - 💪 Gym
  - 🎓 School
  - 🌳 Park
  - 📍 Other
- 📏 **Distance Calculation**: Shows distance from current location to saved points
- 🔍 **Search Functionality**: Easily find saved locations
- 🎯 **Navigation Support**: Quick zoom to selected locations
- 🌓 **Theme Support**: Toggle between dark and light modes
- 💾 **Data Persistence**: Backend integration for reliable data storage

## 🖼️ Screenshots

| ![Location Permission](https://github.com/user-attachments/assets/4171e101-7370-46b9-b053-ad250bda337a) | ![Map Light Mode](https://github.com/user-attachments/assets/2ebd4ef8-5468-41e7-a590-12c2651b5e16) | ![Add Location](https://github.com/user-attachments/assets/cceacbe8-8b74-4754-bcdd-377cddb24144) |
| :-----------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------: |
|                                           Location Permission                                           |                                       Map View (Light Mode)                                        |                                           Add Location                                           |

| ![Map Dark Mode](https://github.com/user-attachments/assets/4250e03c-5cd1-481a-bba2-bd76216a9a69) | ![Edit Location](https://github.com/user-attachments/assets/62480cf5-901b-4e77-8c03-c92174d14642) | ![Search Locations](https://github.com/user-attachments/assets/92fee4f9-03eb-4f75-af46-6211203caa38) |
| :-----------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------: |
|                                       Map View (Dark Mode)                                        |                                  View/Edit Location (Dark Mode)                                   |                                     Search Locations (Dark Mode)                                     |

## 🛠️ Installation

### Prerequisites

1. Install Flutter by following the official guide:

   ```bash
   # Windows
   - Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
   - Extract the zip file and add Flutter to your PATH
   - Run 'flutter doctor' to verify installation

   # macOS
   brew install flutter

   # Linux
   sudo snap install flutter --classic
   ```

2. Get your Google Maps API key:
   - Visit Google Cloud Console
   - Enable Maps SDK for Android/iOS
   - Create credentials (API key)
   - Replace `MY_API_KEY` in the following files:
     - `android/app/src/main/AndroidManifest.xml`
     - `ios/Runner/AppDelegate.swift`

### Project Setup

1. Clone the repository

   ```bash
   git clone https://github.com/yassinezaanouni/mybestlocations_flutter.git
   ```

2. Navigate to project directory

   ```bash
   cd mybestlocations_flutter

   ```

3. Install dependencies

   ```bash
   flutter pub get
   ```

4. Run the app
   ```bash
   flutter run
   ```

## 🗺️ API Key Setup

1. In `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <meta-data
     android:name="com.google.android.geo.API_KEY"
     android:value="MY_API_KEY"/>
   ```

2. In `ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("MY_API_KEY")
   ```

[Previous sections remain the same...]

## 💻 Backend Setup

1. Change the API endpoint in `lib/services/location_service.dart`:

   ```dart
   // Replace this:
   static const String baseUrl = 'https://672e4812229a881691ef992a.mockapi.io/api/locations';

   // With your backend endpoint:
   static const String baseUrl = 'YOUR_BACKEND_ENDPOINT';
   ```

Required API endpoints:

- GET `/locations` - Fetch all locations
- POST `/locations` - Create new location
- PUT `/locations/{id}` - Update location
- DELETE `/locations/{id}` - Delete location

## 🤝 Contributing

This is a reshared university project, but suggestions and improvements are welcome:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

Yassine Zaanouni
www.yassinezaanouni.com

---

⭐️ From Yassine Zaanouni at ISSAT Engineering
