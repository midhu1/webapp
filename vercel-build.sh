#!/bin/bash

# 1. Clone the Flutter stable channel repository (shallow clone to save download time)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Add Flutter to the current session PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable web support explicitly
flutter config --enable-web

# 4. Build the web app in release mode
flutter build web --release
