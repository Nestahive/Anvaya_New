Write-Host "====================================================" -ForegroundColor Green
Write-Host "Starting Anvaya Vision Inference Engine..." -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Set-Location -Path $PSScriptRoot
& "C:\Users\prati\AppData\Roaming\uv\python\cpython-3.11-windows-x86_64-none\python.exe" -m uvicorn app.main:app --app-dir "$PSScriptRoot" --host 0.0.0.0 --port 8000 --reload
