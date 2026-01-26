import 'dart:convert';
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
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;

  const WeatherPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static const String _apiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');
  WeatherService? _weatherService;

  WeatherResponse? _weather;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<CityLocation> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  List<CityLocation> _savedCities = [];
  String? _cacheNotice;

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
    if (_apiKey.isEmpty || _weatherService == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Missing API key. Run with --dart-define=OPENWEATHER_API_KEY=YOUR_KEY.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _cacheNotice = null;
    });

    try {
      final data = await _weatherService!.getWeather(_lat, _lon);

      if (!mounted) return;
      await _saveWeatherCache();
      if (!mounted) return;
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final cached = await _loadWeatherCache();
      if (!mounted) return;
      if (cached != null) {
        setState(() {
          _weather = cached;
          _isLoading = false;
          _errorMessage = null;
          _cacheNotice = "Offline: showing last saved data.";
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to fetch weather. Please try again.";
        });
      }
      debugPrint("Error fetching weather: $e");
    }
  }

  Future<void> _searchCities(String query) async {
    if (_apiKey.isEmpty || _weatherService == null) {
      setState(() {
        _searchError =
            "Missing API key. Run with --dart-define=OPENWEATHER_API_KEY=YOUR_KEY.";
      });
      return;
    }

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
      final results = await _weatherService!.searchCities(query);
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

  String _cacheKey() {
    final lat = _lat.toStringAsFixed(4);
    final lon = _lon.toStringAsFixed(4);
    return "weather_cache_${lat}_$lon";
  }

  Future<void> _saveWeatherCache() async {
    if (_weatherService == null) return;
    final raw = _weatherService!.lastResponseBody;
    if (raw == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(), raw);
  }

  Future<WeatherResponse?> _loadWeatherCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey());
    if (raw == null || raw.isEmpty) return null;
    return WeatherResponse.fromJson(jsonDecode(raw));
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
    final hourlyCount = min(8, _weather!.hourly.length);

    final background = widget.isDark
        ? const [Color(0xFF0D1B2A), Color(0xFF1B263B)]
        : const [Color(0xFFE6F4FF), Color(0xFFB3DAFF)];
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subTextColor = widget.isDark ? Colors.white70 : Colors.black54;
    final cardColor =
        widget.isDark ? Colors.white10 : Colors.white.withOpacity(0.85);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Weather"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDark,
                onChanged: widget.onToggleTheme,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
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
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),

                if (_searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      color: cardColor,
                      child: Column(
                        children: _searchResults.map((city) {
                          return ListTile(
                            title: Text(
                              city.displayName,
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () => _selectCity(city),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.bookmark_add_outlined),
                              onPressed: () => _saveCity(city),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                if (_savedCities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        Text(
                          "Saved Cities",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Card(
                            color: cardColor,
                            child: Column(
                              children: _savedCities.map((city) {
                                return ListTile(
                                  title: Text(
                                    city.displayName,
                                    style: TextStyle(color: textColor),
                                  ),
                                  onTap: () => _selectCity(city),
                                  trailing: IconButton(
                                    icon:
                                        const Icon(Icons.delete_outline),
                                    onPressed: () => _removeCity(city),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_cacheNotice != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _cacheNotice!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                Text(
                  _locationLabel,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),


                Text(
                  "${_weather!.current.temp.round()} °C",
                  style: TextStyle(fontSize: 40, color: textColor),
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
                  style: TextStyle(fontSize: 24, color: subTextColor),
                ),

                const SizedBox(height: 20),

                if (hourlyCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Next 24 hours (3h steps)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                if (hourlyCount > 0)
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: hourlyCount,
                      itemBuilder: (context, index) {
                        final hour = _weather!.hourly[index];
                        return _buildHourlyTile(
                          hour,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        );
                      },
                    ),
                  ),

                if (forecastCount == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "No forecast available.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Column(
                    children: List.generate(forecastCount, (index) {
                      final day = _weather!.daily[index + 1];
                      return _buildDailyTile(day);
                    }),
                  ),
              ],
            ),
          ),
        ),
      );
        
  }

  Widget _buildWeatherIcon(String iconCode, {double size = 40}) {
    final url = "https://openweathermap.org/img/wn/$iconCode@2x.png";
    return Image.network(
      url,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.cloud, size: 24);
      },
    );
  }

  Widget _buildHourlyTile(
    HourlyWeather hour, {
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final time = DateTime.fromMillisecondsSinceEpoch(hour.dt * 1000);
    final timeLabel = "${time.hour.toString().padLeft(2, '0')}:00";

    return Container(
      width: 86,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeLabel,
            style: TextStyle(fontSize: 12, color: subTextColor),
          ),
          const SizedBox(height: 4),
          _buildWeatherIcon(hour.weather[0].icon, size: 32),
          const SizedBox(height: 2),
          Text(
            "${hour.temp.round()}°C",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              hour.weather[0].main,
              style: TextStyle(fontSize: 11, color: subTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
