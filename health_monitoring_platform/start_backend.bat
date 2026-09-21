@echo off
echo Starting Cloud IoT Health Monitoring Backend API...
cd /d "%~dp0backend_api"
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
pause
