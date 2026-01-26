import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_response.dart';
import '../utils/weather_animation.dart';


class DailyDetailPage extends StatelessWidget {
  final DailyWeather day;

  const DailyDetailPage({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(day.dt * 1000);
    final weekday =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];

    return Scaffold(
      appBar: AppBar(
        title: Text("$weekday Details"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "${day.temp.day.round()}°C",
              style: const TextStyle(fontSize: 50),
            ),

            Text(
              day.weather[0].main,
              style: const TextStyle(fontSize: 28),
            ),

            const SizedBox(height: 20),

            Text("High: ${day.temp.max}°C"),
            Text("Low: ${day.temp.min}°C"),
            Text("Humidity: ${day.humidity}%"),
            Text("Wind: ${day.windSpeed} m/s"),
            Text("UV Index: ${day.uvi}"),

            const SizedBox(height: 20),

            // Placeholder for animation (we add Lottie next)
            Lottie.asset(
              getAnimationForWeather(day.weather[0].main),
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),

          ],
        ),
      ),
    );
  }
}
