import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import 'package:intl/intl.dart';

class ForecastPage extends StatelessWidget {
  final List<DayForecast>? forecast;
  final String cityName;

  const ForecastPage({
    Key? key,
    required this.forecast,
    required this.cityName,
  }) : super(key: key);

  Color _getWeatherColor(int index) {
    final colors = [
      Color(0xFF74B9FF),
      Color(0xFF81ECEC),
      Color(0xFF77DD77),
      Color(0xFFFDCB6E),
      Color(0xFFE17055),
    ];
    return colors[index % colors.length];
  }

  Widget _buildForecastItem(DayForecast day, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getWeatherColor(index).withOpacity(0.8),
            _getWeatherColor(index).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE').format(day.date),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                DateFormat('MMM d').format(day.date),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/${day.icon}@2x.png',
                width: 60,
                height: 60,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'High: ${day.maxTemp.toStringAsFixed(0)}° • Low: ${day.minTemp.toStringAsFixed(0)}°',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(Icons.water_drop, '${(day.pop * 100).toInt()}%', 'Rain'),
                _buildDetailItem(Icons.air, '${day.windSpeed.toStringAsFixed(1)} m/s', 'Wind'),
                _buildDetailItem(Icons.opacity, '${day.humidity.toInt()}%', 'Humidity'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return forecast == null || forecast!.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            'No forecast data',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Search for a city to see forecast',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    )
        : Padding( 
      padding: EdgeInsets.only(top: 10, bottom: 10), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              cityName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: forecast!.length,
              itemBuilder: (context, index) {
                return _buildForecastItem(forecast![index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
