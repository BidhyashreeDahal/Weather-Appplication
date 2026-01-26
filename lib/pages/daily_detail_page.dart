import 'package:flutter/material.dart';

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
    final background = getGradientForWeather(
      day.weather[0].main,
      isDark: isDark,
    );
    final accentColor = getAccentColor(
      day.weather[0].main,
      isDark: isDark,
    );
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor =
        isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.95);

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
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${day.temp.day.round()}°C",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accentColor.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        day.weather[0].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Image.network(
                      "https://openweathermap.org/img/wn/${day.weather[0].icon}@2x.png",
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud, size: 48);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                            value: "${day.windSpeed.toStringAsFixed(1)} m/s",
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
