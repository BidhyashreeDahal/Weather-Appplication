class CityLocation {
  final String name;
  final double lat;
  final double lon;
  final String country;
  final String? state;

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
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      country: json['country'],
      state: json['state'],
    );
  }

  String get displayName =>
      state == null || state!.isEmpty ? "$name, $country" : "$name, $state, $country";
}

extension CityLocationStorage on CityLocation {
  String toStorageString() {
    return [
      name,
      lat.toString(),
      lon.toString(),
      country,
      state ?? "",
    ].join("|");
  }

  static CityLocation fromStorageString(String value) {
    final parts = value.split("|");
    return CityLocation(
      name: parts[0],
      lat: double.parse(parts[1]),
      lon: double.parse(parts[2]),
      country: parts[3],
      state: parts.length > 4 && parts[4].isNotEmpty ? parts[4] : null,
    );
  }
}
 
