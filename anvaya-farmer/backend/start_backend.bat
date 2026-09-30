@echo off
echo ====================================================
echo   Starting Anvaya Vision Inference Engine
echo ====================================================
cd /d "%~dp0"
set PYTHONPATH=%~dp0
"C:\Users\prati\AppData\Roaming\uv\python\cpython-3.11-windows-x86_64-none\python.exe" -m uvicorn app.main:app --host 0.0.0.0 --port 8000
pause
