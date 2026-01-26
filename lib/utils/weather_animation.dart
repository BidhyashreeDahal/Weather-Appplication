import 'package:flutter/material.dart';

String getAnimationForWeather(String condition) {
  final normalized = condition.toLowerCase();

  if (normalized.contains("cloud")) return "assets/cloudy.json";
  if (normalized.contains("rain")) return "assets/rain.json";
  if (normalized.contains("snow")) return "assets/snow.json";
  if (normalized.contains("storm") || normalized.contains("thunder")) {
    return "assets/storm.json";
  }

  if (normalized.contains("clear") || normalized.contains("sun")) {
    return "assets/sunny.json";
  }

  if (normalized.contains("fog") || normalized.contains("mist")) {
    return "assets/fog.json";
  }

  return "assets/unknown.json";
}

List<Color> getGradientForWeather(String condition, {required bool isDark}) {
  final normalized = condition.toLowerCase();

  if (normalized.contains("storm") || normalized.contains("thunder")) {
    return isDark
        ? const [Color(0xFF0A0F1C), Color(0xFF1B2342)]
        : const [Color(0xFF3D4E6B), Color(0xFF8FA4C3)];
  }
  if (normalized.contains("rain")) {
    return isDark
        ? const [Color(0xFF0B2233), Color(0xFF174A6F)]
        : const [Color(0xFF5B92C8), Color(0xFFB6D6F2)];
  }
  if (normalized.contains("snow")) {
    return isDark
        ? const [Color(0xFF142033), Color(0xFF2A3B52)]
        : const [Color(0xFFD6EEFF), Color(0xFFF8FBFF)];
  }
  if (normalized.contains("cloud")) {
    return isDark
        ? const [Color(0xFF1C2633), Color(0xFF3A495C)]
        : const [Color(0xFFA6C8E6), Color(0xFFE8F1FA)];
  }
  if (normalized.contains("fog") || normalized.contains("mist")) {
    return isDark
        ? const [Color(0xFF1C2127), Color(0xFF30363D)]
        : const [Color(0xFFD1DAE3), Color(0xFFF2F5F8)];
  }
  if (normalized.contains("clear") || normalized.contains("sun")) {
    return isDark
        ? const [Color(0xFF0B1D2A), Color(0xFF1F4C7A)]
        : const [Color(0xFF61B7FF), Color(0xFFFFE7A3)];
  }

  return isDark
      ? const [Color(0xFF0B1D2A), Color(0xFF1B2B3F)]
      : const [Color(0xFF7AC6FF), Color(0xFFE9F6FF)];
}

Color getAccentColor(String condition, {required bool isDark}) {
  final normalized = condition.toLowerCase();

  if (normalized.contains("storm") || normalized.contains("thunder")) {
    return isDark ? const Color(0xFFB39DFF) : const Color(0xFF5C6BFF);
  }
  if (normalized.contains("rain")) {
    return isDark ? const Color(0xFF7CCBFF) : const Color(0xFF1E78B4);
  }
  if (normalized.contains("snow")) {
    return isDark ? const Color(0xFFD7F0FF) : const Color(0xFF4AA3DF);
  }
  if (normalized.contains("cloud")) {
    return isDark ? const Color(0xFFE6EEF7) : const Color(0xFFF7FAFD);
  }
  if (normalized.contains("fog") || normalized.contains("mist")) {
    return isDark ? const Color(0xFFCAD3DB) : const Color(0xFF768592);
  }
  if (normalized.contains("clear") || normalized.contains("sun")) {
    return isDark ? const Color(0xFFFFD54F) : const Color(0xFFFFB300);
  }

  return isDark ? const Color(0xFF90CAF9) : const Color(0xFF4A90E2);
}
