@echo off
echo Starting Raspberry Pi / Edge Sensor Monitoring Daemon...
cd /d "%~dp0edge_service"
python -m main --interval 2.0
pause
