# 检查是否有进程在使用 5000 端口，如果有则杀掉这些进程
echo "Checking if any process is using port 5000..."
if lsof -i:5000; then
    echo "Killing processes using port 5000..."
    lsof -ti:5000 | xargs kill -9
else
    echo "No process is using port 5000."
fi
