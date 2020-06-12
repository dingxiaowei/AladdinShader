@echo off
echo "=====================提交=================================="
set BatDir=%~dp0
git pull
set/p log=请输入提交日志:

git add .
if "%log%"=="" (git commit -m "自动提交") else (git commit -m %log%)
git push

echo "===================提交成功================================"
pause