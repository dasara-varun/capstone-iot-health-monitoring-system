@echo off
echo Starting Flutter Health Monitoring App on http://127.0.0.1:8080
cd /d "%~dp0flutter_app"
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
pause
