import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_response.dart';
import '../services/weather_service.dart';
import '../utils/weather_animation.dart';
import 'daily_detail_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static const String _apiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');
  late final WeatherService _weatherService;

  WeatherResponse? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (_apiKey.isEmpty) {
      _isLoading = false;
      _errorMessage =
          "Missing API key. Set OPENWEATHER_API_KEY and rebuild.";
      return;
    }

    _weatherService = WeatherService(_apiKey);
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getWeather(
        43.6532,   // Toronto latitude
        -79.3832,  // Toronto longitude
      );

      if (!mounted) return;
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to fetch weather. Please try again.";
      });
      debugPrint("Error fetching weather: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchWeather,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_weather == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No weather data available.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final forecastCount = _weather!.daily.length > 1
        ? min(5, _weather!.daily.length - 1)
        : 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

              
                Text(
                  _weather!.timezone,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                Text(
                  "${_weather!.current.temp.round()} °C",
                  style: const TextStyle(fontSize: 40),
                ),

                // ⭐ MAIN WEATHER ANIMATION ⭐
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                    getAnimationForWeather(
                        _weather!.current.weather[0].main),
                  ),
                ),

                Text(
                  _weather!.current.weather[0].main,
                  style: const TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 20),

               
                Expanded(
                  child: forecastCount == 0
                      ? const Center(
                          child: Text(
                            "No forecast available.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: forecastCount,
                          itemBuilder: (context, index) {
                            final day = _weather!.daily[index + 1];
                            return _buildDailyTile(day);
                          },
                        ),
                ),
              ],
            ),
      ),
    );
  }


  Widget _buildDailyTile(DailyWeather day) {
    final date = DateTime.fromMillisecondsSinceEpoch(day.dt * 1000);
    final weekday =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(
          weekday,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${day.temp.day.round()}°C — ${day.weather[0].main}",
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyDetailPage(day: day),
            ),
          );
        },
      ),
    );
  }
}
