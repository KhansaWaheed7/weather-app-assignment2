import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_models.dart';
import 'package:intl/intl.dart';
import 'forecast_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

enum Status { idle, loading, error }

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  late WeatherService _service;
  CurrentWeather? _current;
  List<DayForecast>? _forecast;
  List<HourlyForecast>? _hourlyForecast;
  Status _status = Status.idle;
  String _errorMessage = '';
  static const String _kLastCityKey = 'last_city';
  static const String _kSearchHistoryKey = 'search_history';
  String? _lastCity;
  List<String> _searchHistory = [];
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _service = WeatherService();
    _loadLastCity();
    _loadSearchHistory();

    _pages.add(_buildHomeContent());
    _pages.add(_buildForecastContent());
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 10), 
          _buildCurrentWeather(),
          SizedBox(height: 24),
          _buildHourlyForecast(),
          SizedBox(height: 24),
          if (_forecast != null && _forecast!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5-DAY FORECAST',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 1; 
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black87),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_forecast != null && _forecast!.isNotEmpty)
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: _forecast!.take(3).map((day) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('EEE').format(day.date),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Image.network(
                                'https://openweathermap.org/img/wn/${day.icon}.png',
                                width: 32,
                                height: 32,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  day.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (day.pop > 0)
                                Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.water_drop, size: 14, color: Colors.blue[800]),
                                      SizedBox(width: 2),
                                      Text(
                                        '${(day.pop * 100).toInt()}%',
                                        style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                '${day.maxTemp.toStringAsFixed(0)}°',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${day.minTemp.toStringAsFixed(0)}°',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 10), 
        ],
      ),
    );
  }

  Widget _buildForecastContent() {
    return ForecastPage(
      forecast: _forecast,
      cityName: _current?.cityName ?? 'Unknown',
    );
  }

  Future<void> _loadLastCity() async {
    final sp = await SharedPreferences.getInstance();
    final city = sp.getString(_kLastCityKey);
    if (city != null) {
      setState(() {
        _lastCity = city;
        _controller.text = city;
      });
      _search(city);
    }
  }

  Future<void> _loadSearchHistory() async {
    final sp = await SharedPreferences.getInstance();
    final history = sp.getStringList(_kSearchHistoryKey) ?? [];
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _saveLastCity(String city) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastCityKey, city);
  }

  Future<void> _addToSearchHistory(String city) async {
    final sp = await SharedPreferences.getInstance();
    _searchHistory.remove(city);
    _searchHistory.insert(0, city);
    if (_searchHistory.length > 5) {
      _searchHistory = _searchHistory.sublist(0, 5);
    }
    await sp.setStringList(_kSearchHistoryKey, _searchHistory);
    setState(() {});
  }

  Future<void> _search(String city) async {
    setState(() {
      _status = Status.loading;
      _errorMessage = '';
    });
    try {
      final curr = await _service.fetchCurrentWeather(city);
      final fc = await _service.fetch5DayForecast(city);
      final hourly = await _service.fetch24HourForecast(city);
      await _saveLastCity(city);
      await _addToSearchHistory(city);
      setState(() {
        _current = curr;
        _forecast = fc;
        _hourlyForecast = hourly;
        _status = Status.idle;
        // Update pages with new data
        _pages[0] = _buildHomeContent();
        _pages[1] = _buildForecastContent();
      });
    } catch (e) {
      setState(() {
        _status = Status.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Color _getBackgroundColor() {
    if (_current == null) return const Color(0xFF74B9FF);

    final temp = _current!.temp;
    if (temp < 0) return const Color(0xFF7886C7);
    if (temp < 10) return const Color(0xFF74B9FF);
    if (temp < 20) return const Color(0xFFA1D6CB);
    if (temp < 30) return const Color(0xFFFDCB6E);
    return const Color(0xFFE17055);
  }

  Color _getCardColor() {
    final baseColor = _getBackgroundColor();
    return baseColor.withOpacity(0.7);
  }

  Color _getCardLightColor() {
    final baseColor = _getBackgroundColor();
    return baseColor.withOpacity(0.3);
  }

  Widget _buildCurrentWeather() {
    if (_current == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBackgroundColor().withOpacity(0.8),
            _getBackgroundColor().withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _current!.cityName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${_current!.country} • ${DateFormat('EEEE, MMM d').format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Image.network(
                'https://openweathermap.org/img/wn/${_current!.icon}@4x.png',
                width: 80,
                height: 80,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${_current!.temp.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _current!.description.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Feels like ${_current!.feelsLike.toStringAsFixed(0)}°',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(Icons.air, '${_current!.windSpeed.toStringAsFixed(1)} m/s'),
                _buildWeatherDetail(Icons.water_drop, '${_current!.humidity}%'),
                _buildWeatherDetail(Icons.compress, '${_current!.pressure} hPa'),
                _buildWeatherDetail(Icons.visibility, '${(_current!.visibility / 1000).toStringAsFixed(1)} km'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    if (_hourlyForecast == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'HOURLY FORECAST',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _hourlyForecast!.length,
              itemBuilder: (context, index) {
                final hour = _hourlyForecast![index];
                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getCardColor(),
                        _getCardLightColor(),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(hour.time),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${hour.icon}.png',
                        width: 32,
                        height: 32,
                      ),
                      Text(
                        '${hour.temp.toStringAsFixed(0)}°',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (hour.pop > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop, size: 12, color: Colors.black),
                            SizedBox(width: 2),
                            Text(
                              '${(hour.pop * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10), 
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) _search(v.trim());
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchHistory.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(Icons.history, color: _getBackgroundColor()),
              onSelected: (city) {
                _controller.text = city;
                _search(city);
              },
              itemBuilder: (context) => _searchHistory
                  .map((city) => PopupMenuItem(
                value: city,
                child: Text(
                  city,
                  style: TextStyle(color: Colors.black),
                ),
              ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_status == Status.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_getBackgroundColor()),
            ),
            SizedBox(height: 20),
            Text(
              'Fetching weather data...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    if (_status == Status.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 80, color: Colors.grey[600]),
              SizedBox(height: 20),
              Text(
                'Unable to fetch weather',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) _search(_controller.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getBackgroundColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_controller.text.trim().isNotEmpty) {
          await _search(_controller.text.trim());
        }
      },
      child: _pages[_currentIndex],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea( 
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea( 
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Forecast',
            ),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
