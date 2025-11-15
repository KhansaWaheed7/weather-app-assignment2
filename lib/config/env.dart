class Env {
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '2b69dc5d6bb2136c9be2e45a2060d9ba',
  );
}