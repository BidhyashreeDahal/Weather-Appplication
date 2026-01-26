import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_response.dart';
import '../models/city_location.dart';

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/3.0/onecall";
  final String apiKey;
  String? _lastResponseBody;

  WeatherService(this.apiKey);

  String? get lastResponseBody => _lastResponseBody;

  Future<WeatherResponse> getWeather(double lat, double lon) async {
    if (apiKey.trim().isEmpty) {
      throw Exception("Missing API key");
    }

    final url =
        "$BASE_URL?lat=$lat&lon=$lon&exclude=minutely&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      _lastResponseBody = response.body;
      return WeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch weather: ${response.body}");
    }
  }

  Future<List<CityLocation>> searchCities(String query) async {
    if (apiKey.trim().isEmpty) {
      throw Exception("Missing API key");
    }

    final url =
        "https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CityLocation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch city locations: ${response.body}");
    }
  }
}
