import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_response.dart';

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/3.0/onecall";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<WeatherResponse> getWeather(double lat, double lon) async {
    if (apiKey.trim().isEmpty) {
      throw Exception("Missing API key");
    }

    final url =
        "$BASE_URL?lat=$lat&lon=$lon&exclude=hourly,minutely&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch weather: ${response.body}");
    }
  }
}
