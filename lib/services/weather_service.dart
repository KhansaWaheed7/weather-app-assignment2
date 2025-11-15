import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';
import 'package:intl/intl.dart';
import '../config/env.dart';

class WeatherService {
  final String apiKey;

  WeatherService({String? apiKey})
      : apiKey = apiKey ?? Env.weatherApiKey;

  Future<CurrentWeather> fetchCurrentWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return CurrentWeather.fromJson(data);
    } else {
      throw Exception(_parseError(res));
    }
  }

  Future<List<DayForecast>> fetch5DayForecast(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception(_parseError(res));
    final data = json.decode(res.body);
    final List items = data['list'];

    Map<String, List<dynamic>> byDate = {};
    for (var item in items) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      String key = DateFormat('yyyy-MM-dd').format(dt);
      byDate.putIfAbsent(key, () => []).add(item);
    }

    List<String> sortedDates = byDate.keys.toList()..sort();
    List<String> targetDates = sortedDates.take(5).toList();
    List<DayForecast> result = [];

    for (var d in targetDates) {
      var entries = byDate[d]!;
      double minT = double.infinity;
      double maxT = -double.infinity;
      Map<String, int> descCount = {};
      Map<String, String> iconForDesc = {};
      double totalPop = 0;
      double totalHumidity = 0;
      double totalWindSpeed = 0;

      for (var e in entries) {
        double t = (e['main']['temp'] as num).toDouble();
        if (t < minT) minT = t;
        if (t > maxT) maxT = t;

        String desc = e['weather'][0]['description'];
        String icon = e['weather'][0]['icon'];
        descCount[desc] = (descCount[desc] ?? 0) + 1;
        iconForDesc[desc] = icon;

        totalPop += (e['pop'] ?? 0) as double;
        totalHumidity += (e['main']['humidity'] as num).toDouble();
        totalWindSpeed += (e['wind']['speed'] as num).toDouble();
      }

      String chosenDesc = descCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      String chosenIcon = iconForDesc[chosenDesc]!;

      result.add(DayForecast(
        date: DateTime.parse(d),
        minTemp: minT,
        maxTemp: maxT,
        description: chosenDesc,
        icon: chosenIcon,
        pop: totalPop / entries.length,
        humidity: totalHumidity / entries.length,
        windSpeed: totalWindSpeed / entries.length,
      ));
    }
    return result;
  }

  Future<List<HourlyForecast>> fetch24HourForecast(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=${Uri.encodeComponent(city)}&units=metric&appid=$apiKey';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception(_parseError(res));
    final data = json.decode(res.body);
    final List items = data['list'];

    List<HourlyForecast> result = [];
    for (var i = 0; i < 8; i++) {
      if (i < items.length) {
        var item = items[i];
        result.add(HourlyForecast(
          time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
          temp: (item['main']['temp'] as num).toDouble(),
          icon: item['weather'][0]['icon'],
          pop: (item['pop'] ?? 0) as double,
          description: item['weather'][0]['description'],
        ));
      }
    }
    return result;
  }

  String _parseError(http.Response res) {
    try {
      final d = json.decode(res.body);
      if (d is Map && d.containsKey('message')) return d['message'];
    } catch (e) {}
    return 'HTTP ${res.statusCode}';
  }
}