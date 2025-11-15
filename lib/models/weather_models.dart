class CurrentWeather {
  final String cityName;
  final double temp;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;
  final double feelsLike;
  final int pressure;
  final int visibility;
  final double? rain;
  final int sunrise;
  final int sunset;
  final String country;

  CurrentWeather({
    required this.cityName,
    required this.temp,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    this.rain,
    required this.sunrise,
    required this.sunset,
    required this.country,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      cityName: json['name'],
      temp: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      icon: json['weather'][0]['icon'],
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      pressure: json['main']['pressure'],
      visibility: json['visibility'] ?? 0,
      rain: json['rain'] != null ? (json['rain']['1h'] as num).toDouble() : null,
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      country: json['sys']['country'],
    );
  }
}

class DayForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;
  final double pop;
  final double humidity;
  final double windSpeed;

  DayForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
    required this.pop,
    required this.humidity,
    required this.windSpeed,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temp;
  final String icon;
  final double pop;
  final String description;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
    required this.pop,
    required this.description,
  });
}