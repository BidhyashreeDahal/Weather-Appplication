🌤️ Weather Divining App (Flutter)

A modern Flutter application that displays real-time weather data and a 5-day forecast using the OpenWeather One Call API.
The app features animated weather visuals, a clean UI, and detailed daily forecasts.

✨ Features

📍 Location search with saved cities

🌡️ Current temperature and weather conditions

🕒 Hourly forecast (next 12 hours)

📆 Scrollable 5-day weather forecast

🔍 Detailed daily view with:

High / Low temperature

Humidity

Wind speed

UV index

🎞️ Dynamic Lottie animations based on weather conditions

🖼️ Weather icons for hourly forecast

🌓 Light/dark theme toggle

📴 Offline cache of last successful response

📱 Responsive layout with a static header and scrollable content

🛠️ Tech Stack

Flutter (Dart)

OpenWeather One Call API

http – API requests

lottie – animated weather visuals

shared_preferences – local persistence

ListView.builder – dynamic forecast lists

Flutter navigation for multi-screen flow

🌐 API Integration

OpenWeather One Call API

https://api.openweathermap.org/data/3.0/onecall


Data used:

Current weather

Hourly forecast

Daily forecast

Metric units

Latitude & longitude based queries

📂 Project Structure
lib/
 ├── pages/
 │    ├── weather_page.dart
 │    └── daily_detail_page.dart
 ├── services/
 │    └── weather_service.dart
 ├── models/
 │    ├── weather_response.dart
 │    └── city_location.dart
 ├── utils/
 │    └── weather_animation.dart
assets/
 ├── sunny.json
 ├── cloudy.json
 ├── rain.json
 ├── snow.json
 └── storm.json

▶️ Getting Started

Clone the repository

Install dependencies:

flutter pub get

Run the app (API key required):

flutter run --dart-define=OPENWEATHER_API_KEY=YOUR_KEY


Supports Android emulator and web (Chrome).

📸 Screenshots

(Optional — add screenshots here to showcase the UI)

🚀 Future Improvements

Current location button (GPS)

Hourly forecast chart

Better empty states and animations

👤 Author

Bidhyashree Dahal