import 'package:http/http.dart' as http;
import 'dart:convert';

class Weather {
  final String apiKey;
  final String city;

  Weather({required this.apiKey, required this.city});

  Future<WeatherData> fetchWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherData {
  final double temperature;
  final String weatherDescription;
  final List<ForecastData> forecastData;

  WeatherData({
    required this.temperature,
    required this.weatherDescription,
    required this.forecastData,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final temperature = json['main']['temp'].toDouble();
    final weatherDescription = json['weather'][0]['description'];
    final forecastList =
        json['list'] != null ? json['list'] as List<dynamic> : [];

    final forecastData = forecastList.map((forecastJson) {
      final date = DateTime.fromMillisecondsSinceEpoch(
              forecastJson['dt'] * 1000,
              isUtc: true)
          .toLocal();
      final maxTemperature = forecastJson['temp']['max'].toDouble();
      final minTemperature = forecastJson['temp']['min'].toDouble();
      final weatherIcon = forecastJson['weather'][0]['icon'];
      return ForecastData(
        date: date,
        maxTemperature: maxTemperature,
        minTemperature: minTemperature,
        weatherIcon: weatherIcon,
      );
    }).toList();

    return WeatherData(
      temperature: temperature,
      weatherDescription: weatherDescription,
      forecastData: forecastData,
    );
  }
}

class ForecastData {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String weatherIcon;

  ForecastData({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherIcon,
  });
}
