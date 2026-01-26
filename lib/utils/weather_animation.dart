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
