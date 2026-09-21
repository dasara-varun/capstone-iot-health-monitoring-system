@echo off
echo ========================================================
echo  RUNNING ALL CAPSTONE REVIEW-2 TEST SUITES
echo ========================================================
echo.
echo [1/3] Backend API Tests...
cd /d "%~dp0"
python -m unittest discover -s backend_api/tests -t .
if %errorlevel% neq 0 (
    echo Backend tests failed!
    pause
    exit /b %errorlevel%
)

echo.
echo [2/3] Edge Service Tests...
python -m unittest discover -s edge_service/tests -t .
if %errorlevel% neq 0 (
    echo Edge tests failed!
    pause
    exit /b %errorlevel%
)

echo.
echo [3/3] Flutter App Widget Tests...
cd /d "%~dp0flutter_app"
call flutter test
if %errorlevel% neq 0 (
    echo Flutter tests failed!
    pause
    exit /b %errorlevel%
)

echo.
echo [4/4] End-to-End Live Pipeline Demonstration...
cd /d "%~dp0"
python run_demo.py

echo.
echo ========================================================
echo  ALL TEST SUITES AND DEMOS COMPLETED SUCCESSFULLY!
echo ========================================================
pause
