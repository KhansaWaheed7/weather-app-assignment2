# Weather App

A Flutter mobile weather application that displays current weather and 5-day forecasts.

## Features
- Current weather (temperature, description, humidity, wind speed)
- 5-day weather forecast
- City search with history
- Local storage for last-searched city
- Error handling for network issues

## UI
<img width="722" height="1673" alt="home1" src="https://github.com/user-attachments/assets/aede2d60-62f5-4528-8d91-7b90fe1aa8c8" /> <img width="722" height="1673" alt="home2" src="https://github.com/user-attachments/assets/c8c5551e-92b5-46cf-b3eb-fb7bfe35eb4a" /> <img width="722" height="1673" alt="home3" src="https://github.com/user-attachments/assets/d5ef4160-9416-4caf-9669-14c0e22b326a" /> <img width="722" height="1673" alt="Forecast1" src="https://github.com/user-attachments/assets/aff4d791-747a-4f5f-aa84-a4a409ac141b" /> <img width="722" height="1673" alt="Forecast2" src="https://github.com/user-attachments/assets/feef29f0-b514-4a89-95f1-21e0cf492c00" /> <img width="722" height="1673" alt="incorrect" src="https://github.com/user-attachments/assets/7c85eaa7-c842-4736-a858-80a13b0c9892" />

## Quick Setup

### 1. Get API Key
- Go to [OpenWeatherMap](https://openweathermap.org/api)
- Sign up for free account
- Get your API key from dashboard

### 2. Run the App
```bash
# Clone and navigate to project
git clone <repo-url>
cd weather-app

# Install dependencies
flutter pub get

# Run with your API key
flutter run --dart-define=WEATHER_API_KEY=your_api_key_here
```

## Project Structure
```
lib/
├── main.dart
├── config/env.dart          # API key configuration
├── models/weather_models.dart
├── pages/
│   ├── home_page.dart
│   └── forecast_page.dart
└── services/weather_service.dart
```

## Build for Release
```bash
flutter build apk --dart-define=WEATHER_API_KEY=your_key_here
```

## API Key Location
The API key is configured in `lib/config/env.dart` and passed via environment variables for security.
