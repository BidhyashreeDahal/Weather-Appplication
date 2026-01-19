class Weather {
  final double temperature;
  final String condition;

  Weather({
    required this.temperature,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json["current"]["temp"].toDouble(),
      condition: json["current"]["weather"][0]["main"],
    );
  }
}
