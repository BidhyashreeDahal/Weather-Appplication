class CityLocation {
  final String name;
  final double lat;
  final double lon;
  final String country;
  final String ? state;

  CityLocation({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
    this.state,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    return CityLocation(
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
      country: json['country'],
      state: json['state'],
    );
  }

String get displayName =>
 state == null || state!.isEmpty ? "$name, $country" : "$name, $state, $country";
}
 
