@echo off


for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000') do (
    echo Killing process using port 5000 with PID %%a using command taskkill /PID %%a /F
    taskkill /PID %%a /F
)
