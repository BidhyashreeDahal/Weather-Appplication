import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_response.dart';
import 'daily_detail_page.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService =
      WeatherService("6c287a0a60da34f0725f72b519b8d94e");

  WeatherResponse? _weather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  _fetchWeather() async {
    try {
      final data = await _weatherService.getWeather(
        43.6532,   // Toronto latitude
        -79.3832,  // Toronto longitude
      );

      setState(() {
        _weather = data;
      });
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }


  String _getAnimationForWeather(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains("cloud")) return "assets/cloudy.json";
    if (condition.contains("rain")) return "assets/rain.json";
    if (condition.contains("snow")) return "assets/snow.json";
    if (condition.contains("storm") || condition.contains("thunder")) {
      return "assets/storm.json";
    }

    return "assets/sunny.json"; // default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _weather == null
          ? const Center(
              child: Text(
                "Loading...",
                style: TextStyle(fontSize: 32),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

              
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
                    _getAnimationForWeather(
                        _weather!.current.weather[0].main),
                  ),
                ),

                Text(
                  _weather!.current.weather[0].main,
                  style: const TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 20),

               
                Expanded(
                  child: ListView.builder(
                    itemCount: 5, // next 5 days
                    itemBuilder: (context, index) {
                      final day = _weather!.daily[index + 1];
                      return _buildDailyTile(day);
                    },
                  ),
                ),
              ],
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
