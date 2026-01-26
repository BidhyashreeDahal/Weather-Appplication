import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_response.dart';
import '../services/weather_service.dart';
import '../utils/weather_animation.dart';
import 'daily_detail_page.dart';
import '../models/city_location.dart';

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
  final TextEditingController _searchController = TextEditingController();
  List<CityLocation> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  List<CityLocation> _savedCities = [];

  double _lat = 43.6532;
  double _lon = -79.3832;
  String _locationLabel = "Toronto";

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
    _loadSavedCities();
    _fetchWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getWeather(_lat, _lon);

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

  Future<void> _searchCities(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await _weatherService.searchCities(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchError = "Failed to search cities.";
      });
    }
  }

  void _selectCity(CityLocation city) {
    setState(() {
      _lat = city.lat;
      _lon = city.lon;
      _locationLabel = city.displayName;
      _searchResults = [];
      _searchController.clear();
    });
    _fetchWeather();
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("saved_cities") ?? [];
    if (!mounted) return;
    setState(() {
      _savedCities =
          data.map(CityLocationStorage.fromStorageString).toList();
    });
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _savedCities.map((c) => c.toStorageString()).toList();
    await prefs.setStringList("saved_cities", data);
  }

  void _saveCity(CityLocation city) {
    final exists =
        _savedCities.any((c) => c.lat == city.lat && c.lon == city.lon);
    if (exists) return;

    setState(() {
      _savedCities.add(city);
    });
    _saveCities();
  }

  void _removeCity(CityLocation city) {
    setState(() {
      _savedCities.removeWhere(
          (c) => c.lat == city.lat && c.lon == city.lon);
    });
    _saveCities();
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchCities,
                    decoration: InputDecoration(
                      hintText: "Search city...",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            _searchCities(_searchController.text),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(),
                  ),

                if (_searchError != null)
                  Text(
                    _searchError!,
                    style: const TextStyle(color: Colors.red),
                  ),

                if (_searchResults.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final city = _searchResults[index];
                        return ListTile(
                          title: Text(city.displayName),
                          onTap: () => _selectCity(city),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.bookmark_add_outlined),
                            onPressed: () => _saveCity(city),
                          ),
                        );
                      },
                    ),
                  ),

                if (_savedCities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        const Text(
                          "Saved Cities",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            itemCount: _savedCities.length,
                            itemBuilder: (context, index) {
                              final city = _savedCities[index];
                              return ListTile(
                                title: Text(city.displayName),
                                onTap: () => _selectCity(city),
                                trailing: IconButton(
                                  icon:
                                      const Icon(Icons.delete_outline),
                                  onPressed: () => _removeCity(city),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              
                Text(
                  _locationLabel,
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
