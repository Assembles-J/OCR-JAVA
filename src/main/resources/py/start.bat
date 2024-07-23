@echo off

rem Display the current directory
dir
python --version

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Python 3.8.4...

    rem Download and install Python 3.8.4
    curl -s -o python-installer.exe https://www.python.org/ftp/python/3.8.4/python-3.8.4.exe
    python-installer.exe /quiet InstallAllUsers=1 PrependPath=1

    rem Wait for Python to be installed (adjust the wait time as needed)
    timeout /t 30 /nobreak >nul
)

rem Create and activate Python virtual environment
python -m venv ocr
call ocr\Scripts\activate

rem Install Python dependencies
pip install -r requirements.txt
rem 下面是手动使用官源
rem pip install -r requirements.txt -i https://pypi.org/simple
rem pip install -r requirements.txt -i  https://pypi.tuna.tsinghua.edu.cn/simple
rem pip install -r requirements.txt -i  https://pypi.mirrors.ustc.edu.cn/simple
pip install paddlenlp
rem Check if any process is using port 5000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000') do (
    echo Killing process using port 5000 with PID %%a using command taskkill /PID %%a /F
    taskkill /PID %%a /F
)


rem Run the Python script (flaskocr.py) in a new window and redirect output to log files
rem start cmd /k python flaskocr.py > flaskocr_output.log 2> flaskocr_error.log
rem start cmd /k python flaskocr.py
python flaskocr.py

rem Optionally, you can keep the script running to monitor the Flask server logs
rem You can use the "timeout" command to keep the script open for a certain amount of time
rem timeout /t 86400 >nul
