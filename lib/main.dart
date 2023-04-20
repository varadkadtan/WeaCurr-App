import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'currency.dart';
import 'settings.dart';
import 'weather.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: MyHomePage(
        title: 'WeaCurr by Varad',
        key: UniqueKey(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Weather _weather =
      Weather(apiKey: 'bbdd99dfdd9262f22abf9faf81c64567', city: '');
  Currency currency = Currency(name: '', exchangeRate: 0, code: '');
  Settings _settings = Settings();
  List<dynamic> _currencyData = [];
  bool _isLoadingCurrency = false;
  Future<Map<String, dynamic>> getWeatherData() async {
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=London&limit=7&appid=bbdd99dfdd9262f22abf9faf81c64567';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> weatherData = json.decode(response.body);
    return weatherData;
  }

  static Future<CurrencyData> fetchCurrencyData(String countryCode) async {
    final response = await http.get(Uri.parse(
        'https://exchange-rates.abstractapi.com/v1/live/?api_key=87014b01836c415195c5db3d8ec554a2&base=$countryCode'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return CurrencyData.fromJson(jsonData, countryCode);
    } else {
      throw Exception('Failed to load currency data');
    }
  }

  String getCurrencyCode(String? city) {
    final countryToCode = {
      'New York': 'USD',
      'London': 'GBP',
      'Dubai': 'AED',
      'Mumbai': 'INR',
      'Tokyo': 'JPY',
      'Moscow': 'RUB',
      'Toronto': 'CAD',
    };
    return countryToCode[city] ?? 'USD';
  }

  // map of city names to latitudes and longitudes
  final Map<String, List<double>> cityCoords = {
    'United States - New York': [40.7128, -74.0060],
    'United Kingdom - London': [51.5074, -0.1278],
    'UAE - Dubai': [25.2048, 55.2708],
    'India - Mumbai': [19.0760, 72.8777],
    'Japan - Tokyo': [35.6762, 139.6503],
    'Russia - Moscow': [55.7558, 37.6173],
    'Canada - Toronto': [43.6532, -79.3832],
  };

  @override
  void initState() {
    super.initState();
    _settings = Settings();
  }

  Widget _buildWeatherTab() {
    final city = _settings.selectedCity;
    final weather = Weather(
      apiKey: 'bbdd99dfdd9262f22abf9faf81c64567',
      city: city!,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.purple],
        ),
      ),
      child: FutureBuilder<WeatherData>(
        future: weather.fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final weatherData = snapshot.data!;
            final temperature = weatherData.temperature;
            final weatherDescription = weatherData.weatherDescription;
            final forecastData = weatherData.forecastData;
            final forecastDays = forecastData.length > 7
                ? forecastData.sublist(0, 7)
                : forecastData;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/4052/4052984.png',
                  width: 280.0,
                ),
                Text(
                  '$city',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Temperature: ${temperature.toStringAsFixed(1)} °C',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Weather: $weatherDescription',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: forecastDays.map((data) {
                    final date = DateFormat('EEE, MMM d').format(data.date);
                    final icon = _getWeatherIcon(data.weatherIcon);
                    final maxTemp = data.maxTemperature.toStringAsFixed(1);
                    final minTemp = data.minTemperature.toStringAsFixed(1);
                    return Column(
                      children: [
                        Text(
                          '$date',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Max: $maxTemp °C',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Min: $minTemp °C',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '02d':
        return Icons.wb_cloudy;
      case '03d':
        return Icons.cloud;
      case '04d':
        return Icons.cloud_queue;
      case '09d':
        return Icons.grain;
      case '10d':
        return Icons.beach_access;
      case '11d':
        return Icons.flash_on;
      case '13d':
        return Icons.ac_unit;
      case '50d':
        return Icons.blur_on;
      default:
        return Icons.error;
    }
  }

  Widget _buildCurrencyTab(BuildContext context) {
    final String countryCode = getCurrencyCode(_settings.selectedCity);
    return FutureBuilder<CurrencyData>(
      future: fetchCurrencyData(countryCode),
      builder: (BuildContext context, AsyncSnapshot<CurrencyData> snapshot) {
        if (snapshot.hasData) {
          final currencyData = snapshot.data!;
          final String baseCurrency = currencyData.baseCurrency;
          final Map<String, double> rates = currencyData.exchangeRates;
          final double? usdToBase = rates[baseCurrency];

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.purple],
              ),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Exchange Rates (${currencyData.baseCurrency})',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 30.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: rates.length,
                    itemBuilder: (context, index) {
                      final currency = rates.keys.elementAt(index);
                      final rate = rates[currency]!;
                      final convertedRate = (usdToBase ?? 1.0) * rate;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currency,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              convertedRate.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.subtitle2,
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
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load currency data: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSettingsTab() {
    final cities = [
      'New York',
      'London',
      'Dubai',
      'Mumbai',
      'Tokyo',
      'Moscow',
      'Toronto',
    ];

    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(40.0),
          children: [
            Text(
              'Show Weather:',
              style: TextStyle(fontSize: 30.0),
            ),
            Switch(
              value: _settings.showWeather,
              onChanged: (value) {
                setState(() {
                  _settings.showWeather = value;
                });
              },
            ),
            Text(
              'Show Currency:',
              style: TextStyle(fontSize: 30.0),
            ),
            Switch(
              value: _settings.showCurrency,
              onChanged: (value) {
                setState(() {
                  _settings.showCurrency = value;
                });
              },
            ),
            SizedBox(height: 30.0),
            Text(
              'Select City:',
              style: TextStyle(fontSize: 30.0),
            ),
            DropdownButton<String>(
              value: _settings.selectedCity,
              onChanged: (String? value) {
                setState(() {
                  _settings.selectedCity = value ?? '';
                });
              },
              items: <String>[
                'New York',
                'London',
                'Dubai',
                'Mumbai',
                'Tokyo',
                'Moscow',
                'Toronto'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildTabBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _settings.selectedTabIndex,
        onTap: (int index) {
          setState(() {
            _settings.selectedTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Currency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody() {
    if (_settings.selectedTabIndex == 0) {
      if (_settings.showWeather) {
        return _buildWeatherTab();
      } else {
        return Center(child: Text('Weather widget disabled.'));
      }
    } else if (_settings.selectedTabIndex == 1) {
      if (_settings.showCurrency) {
        return _buildCurrencyTab(context);
      } else {
        return Center(child: Text('Currency widget disabled.'));
      }
    } else if (_settings.selectedTabIndex == 2) {
      return _buildSettingsTab();
    }
    return Container();
  }
}
