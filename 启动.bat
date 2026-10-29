@echo off
chcp 65001 >nul
setlocal
title MC 下载器
set "APP_DIR=%~dp0"
set "PY="

rem 1) 系统里可用且带 tkinter 的 python
for %%C in (python.exe python3.exe) do (
  if not defined PY (
    where %%C >nul 2>nul && (
      %%C -c "import tkinter" >nul 2>nul && set "PY=%%C"
    )
  )
)

rem 2) py 启动器
if not defined PY (
  where py >nul 2>nul && py -3 -c "import tkinter" >nul 2>nul && set "PY=py -3"
)

rem 3) DSH 自带 Python 运行时
if not defined PY (
  if exist "%USERPROFILE%\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe" (
    set "PY=%USERPROFILE%\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe"
  )
)

if not defined PY (
  echo [x] 没有找到可用的 Python 3。
  echo     请安装 Python 3.9 及以上版本，安装时勾选 Add Python to PATH。
  echo     下载地址: https://www.python.org/downloads/
  pause
  exit /b 1
)

rem 带参数时走命令行模式，否则打开图形界面
if "%~1"=="" (
  start "" %PY% "%APP_DIR%main.py"
) else (
  %PY% "%APP_DIR%main.py" %*
)
endlocal
