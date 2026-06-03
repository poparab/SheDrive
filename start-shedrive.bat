@echo off
title SheDrive — Local Dev Server
cd /d "D:\Claude\SheDrive\shedrive-web"

echo.
echo  ================================
echo   SheDrive  Local Dev Server
echo  ================================
echo.
echo   Rider app   ^>  http://localhost:8000/rider/
echo   Driver app  ^>  http://localhost:8000/driver/
echo.
echo   Press Ctrl+C to stop the server.
echo  ================================
echo.

REM Open the rider home in the default browser after a 1-second delay
REM (gives the server time to bind the port first)
start "" cmd /c "timeout /t 1 /nobreak >nul && start http://localhost:8000/rider/index.html"

REM Start server — this line blocks until you press Ctrl+C
py -m http.server 8000

echo.
echo  Server stopped.
pause
