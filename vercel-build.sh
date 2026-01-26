#!/usr/bin/env bash
set -e
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PWD/flutter/bin:$PATH"
flutter pub get
flutter build web --dart-define=OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY
