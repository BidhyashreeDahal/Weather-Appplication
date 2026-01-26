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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const [Color(0xFF0D1B2A), Color(0xFF1B263B)]
        : const [Color(0xFFE6F4FF), Color(0xFFB3DAFF)];
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? Colors.white10 : Colors.white.withOpacity(0.85);

    return Scaffold(
      appBar: AppBar(
        title: Text("$weekday Details"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: background,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      weekday,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${day.temp.day.round()}°C",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      day.weather[0].main,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: subTextColor),
                    ),
                    const SizedBox(height: 12),
                    Lottie.asset(
                      getAnimationForWeather(day.weather[0].main),
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: cardColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: "High",
                        value: "${day.temp.max.round()}°C",
                        valueColor: textColor,
                        labelColor: subTextColor,
                      ),
                      _InfoRow(
                        label: "Low",
                        value: "${day.temp.min.round()}°C",
                        valueColor: textColor,
                        labelColor: subTextColor,
                      ),
                      _InfoRow(
                        label: "Humidity",
                        value: "${day.humidity}%",
                        valueColor: textColor,
                        labelColor: subTextColor,
                      ),
                      _InfoRow(
                        label: "Wind",
                        value: "${day.windSpeed} m/s",
                        valueColor: textColor,
                        labelColor: subTextColor,
                      ),
                      _InfoRow(
                        label: "UV Index",
                        value: "${day.uvi}",
                        valueColor: textColor,
                        labelColor: subTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: labelColor)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
