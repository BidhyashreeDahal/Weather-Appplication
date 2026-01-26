import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_response.dart';
import '../models/city_location.dart';

class WeatherService {
  static const _currentUrl = "https://api.openweathermap.org/data/2.5/weather";
  static const _forecastUrl =
      "https://api.openweathermap.org/data/2.5/forecast";
  final String apiKey;
  String? _lastResponseBody;

  WeatherService(this.apiKey);

  String? get lastResponseBody => _lastResponseBody;

  Future<WeatherResponse> getWeather(double lat, double lon) async {
    if (apiKey.trim().isEmpty) {
      throw Exception("Missing API key");
    }

    final currentUri = Uri.parse(
        "$_currentUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey");
    final forecastUri = Uri.parse(
        "$_forecastUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey");

    final currentResponse = await http.get(currentUri);
    if (currentResponse.statusCode != 200) {
      throw Exception("Failed to fetch weather: ${currentResponse.body}");
    }

    final forecastResponse = await http.get(forecastUri);
    if (forecastResponse.statusCode != 200) {
      throw Exception("Failed to fetch forecast: ${forecastResponse.body}");
    }

    final currentJson = jsonDecode(currentResponse.body);
    final forecastJson = jsonDecode(forecastResponse.body);
    _lastResponseBody = jsonEncode({
      "current": currentJson,
      "forecast": forecastJson,
    });

    return _mapToWeatherResponse(currentJson, forecastJson);
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

WeatherResponse _mapToWeatherResponse(
  Map<String, dynamic> currentJson,
  Map<String, dynamic> forecastJson,
) {
  final List<dynamic> forecastList = forecastJson["list"] ?? [];
  final int timezoneOffset =
      (currentJson["timezone"] as num?)?.toInt() ?? 0;

  final currentWeather = CurrentWeather(
    dt: (currentJson["dt"] as num?)?.toInt() ?? 0,
    sunrise: (currentJson["sys"]?["sunrise"] as num?)?.toInt() ?? 0,
    sunset: (currentJson["sys"]?["sunset"] as num?)?.toInt() ?? 0,
    temp: (currentJson["main"]?["temp"] as num?)?.toDouble() ?? 0,
    feelsLike: (currentJson["main"]?["feels_like"] as num?)?.toDouble() ?? 0,
    pressure: (currentJson["main"]?["pressure"] as num?)?.toInt() ?? 0,
    humidity: (currentJson["main"]?["humidity"] as num?)?.toInt() ?? 0,
    dewPoint: 0,
    uvi: 0,
    clouds: (currentJson["clouds"]?["all"] as num?)?.toInt() ?? 0,
    visibility: (currentJson["visibility"] as num?)?.toInt() ?? 0,
    windSpeed: (currentJson["wind"]?["speed"] as num?)?.toDouble() ?? 0,
    windDeg: (currentJson["wind"]?["deg"] as num?)?.toInt() ?? 0,
    windGust: (currentJson["wind"]?["gust"] as num?)?.toDouble(),
    weather: ((currentJson["weather"] as List?) ?? [])
        .map((w) => Weather.fromJson(w))
        .toList(),
  );

  final hourly = forecastList.take(12).map((hour) {
    return HourlyWeather(
      dt: (hour["dt"] as num?)?.toInt() ?? 0,
      temp: (hour["main"]?["temp"] as num?)?.toDouble() ?? 0,
      weather: ((hour["weather"] as List?) ?? [])
          .map((w) => Weather.fromJson(w))
          .toList(),
    );
  }).toList();

  final Map<String, List<Map<String, dynamic>>> byDate = {};
  for (final item in forecastList) {
    final dt = (item["dt"] as num?)?.toInt() ?? 0;
    final local = DateTime.fromMillisecondsSinceEpoch((dt + timezoneOffset) * 1000,
        isUtc: true);
    final key = "${local.year}-${local.month}-${local.day}";
    byDate.putIfAbsent(key, () => []);
    byDate[key]!.add(Map<String, dynamic>.from(item));
  }

  final daily = <DailyWeather>[];
  for (final entry in byDate.entries) {
    final dayItems = entry.value;
    if (dayItems.isEmpty) continue;

    double minTemp = double.infinity;
    double maxTemp = -double.infinity;
    double sumTemp = 0;
    double sumHumidity = 0;
    double sumWind = 0;

    for (final item in dayItems) {
      final temp = (item["main"]?["temp"] as num?)?.toDouble() ?? 0;
      minTemp = minTemp > temp ? temp : minTemp;
      maxTemp = maxTemp < temp ? temp : maxTemp;
      sumTemp += temp;
      sumHumidity += (item["main"]?["humidity"] as num?)?.toDouble() ?? 0;
      sumWind += (item["wind"]?["speed"] as num?)?.toDouble() ?? 0;
    }

    final avgTemp = sumTemp / dayItems.length;
    final avgHumidity = (sumHumidity / dayItems.length).round();
    final avgWind = sumWind / dayItems.length;

    final first = dayItems.first;
    final dt = (first["dt"] as num?)?.toInt() ?? 0;

    daily.add(DailyWeather(
      dt: dt,
      sunrise: 0,
      sunset: 0,
      moonrise: 0,
      moonset: 0,
      moonPhase: 0,
      summary: "",
      temp: Temp(
        day: avgTemp,
        min: minTemp.isFinite ? minTemp : avgTemp,
        max: maxTemp.isFinite ? maxTemp : avgTemp,
        night: avgTemp,
        eve: avgTemp,
        morn: avgTemp,
      ),
      feelsLike: FeelsLike(
        day: avgTemp,
        night: avgTemp,
        eve: avgTemp,
        morn: avgTemp,
      ),
      pressure: (first["main"]?["pressure"] as num?)?.toInt() ?? 0,
      humidity: avgHumidity,
      dewPoint: 0,
      windSpeed: avgWind,
      windDeg: (first["wind"]?["deg"] as num?)?.toInt() ?? 0,
      windGust: (first["wind"]?["gust"] as num?)?.toDouble(),
      weather: ((first["weather"] as List?) ?? [])
          .map((w) => Weather.fromJson(w))
          .toList(),
      clouds: (first["clouds"]?["all"] as num?)?.toInt() ?? 0,
      pop: (first["pop"] as num?)?.toDouble() ?? 0,
      rain: (first["rain"]?["3h"] as num?)?.toDouble(),
      snow: (first["snow"]?["3h"] as num?)?.toDouble(),
      uvi: 0,
    ));
  }

  return WeatherResponse(
    lat: (currentJson["coord"]?["lat"] as num?)?.toDouble() ?? 0,
    lon: (currentJson["coord"]?["lon"] as num?)?.toDouble() ?? 0,
    timezone: (currentJson["name"] as String?) ?? "Unknown",
    timezoneOffset: timezoneOffset,
    current: currentWeather,
    hourly: hourly,
    daily: daily,
  );
}
