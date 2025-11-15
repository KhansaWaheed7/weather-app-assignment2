# Weather App

A Flutter mobile weather application that displays current weather and 5-day forecasts.

## Features
- Current weather (temperature, description, humidity, wind speed)
- 5-day weather forecast
- City search with history
- Local storage for last-searched city
- Error handling for network issues

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
