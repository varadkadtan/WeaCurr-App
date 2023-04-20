import 'dart:convert';
import 'package:http/http.dart' as http;

class Currency {
  final String name;
  final String code;
  double exchangeRate;

  Currency({required this.name, required this.code, this.exchangeRate = 0.0});

  factory Currency.fromJson(Map<String, dynamic> json, String countryCode) {
    String currencyCode = json['code'];
    if (currencyCode == countryCode) {
      return Currency(
          name: json['name'], code: currencyCode, exchangeRate: 1.0);
    } else {
      return Currency(name: json['name'], code: currencyCode);
    }
  }
}

class CurrencyData {
  final String baseCurrency;
  final Map<String, double> exchangeRates;
  final String countryCode;

  CurrencyData({
    required this.baseCurrency,
    required this.exchangeRates,
    required this.countryCode,
  });

  factory CurrencyData.fromJson(Map<String, dynamic> json, String countryCode) {
    final Map<String, dynamic> ratesJson = json['exchange_rates'];
    final Map<String, double> rates = {};
    ratesJson.forEach((key, value) {
      rates[key] = value.toDouble();
    });

    return CurrencyData(
      baseCurrency: json['base'],
      exchangeRates: rates,
      countryCode: countryCode,
    );
  }
}
