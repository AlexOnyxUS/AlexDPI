@echo off
title AlexDPI v6.1 - Disorder Optimization
chcp 65001 >nul
cd /d "%~dp0"

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ЗАПУСТИ ОТ АДМИНА!
    pause
    exit
)

:MENU
cls
echo.
echo  ----------------------------------------------------------
echo     ___   _       _______  _  _    ____   ____   _ 
echo    / _ \ / \     |  ____/ | || |  |  _ \ |  _ \ | |
echo   / /_\ \\ \     | |__    \  /   | | | || |_) || |
echo   |  _  | \ \    |  __|   /  \   | | | ||  __/ | |
echo   | | | | / /___ | |____ / /\ \  | |_| || |    | |
echo   |_| |_|/_____/ |______/_/  \_\ |____/ |_|    |_|
echo.
echo  ----------------------------------------------------------
echo               PROJECT: AlexDPI v6.1
echo  ----------------------------------------------------------
echo.
echo   1) STRAT: DISORDER (Стандарт)
echo   2) STRAT: DISORDER-UDP (YouTube Fix + NoQUIC)
echo   3) STRAT: DISORDER-SEQ (Advanced Overlay)
echo   4) STRAT: DISORDER-AUTO-TTL (Smart distance)
echo.
echo   5) STOP / RESET
echo   6) EXIT
echo.
echo  ----------------------------------------------------------
set /p opt="Выбор стратегии: "

if "%opt%"=="1" goto RUN_DIS
if "%opt%"=="2" goto RUN_DIS_UDP
if "%opt%"=="3" goto RUN_DIS_SEQ
if "%opt%"=="4" goto RUN_DIS_TTL
if "%opt%"=="5" goto STOP
if "%opt%"=="6" exit
goto MENU

:RUN_DIS
call :PREPARE
echo [*] Запуск: Стандартный Disorder...
start /b winws.exe --wf-l3=ipv4 --wf-tcp=80,443 --dpi-desync=disorder2 --dpi-desync-split-pos=1
echo [+] Активно.
pause
goto MENU

:RUN_DIS_UDP
call :PREPARE
echo [*] Запуск: Disorder + QUIC Block...
start /b winws.exe --wf-l3=ipv4 --wf-udp=443 --dpi-desync=fake --new --wf-tcp=80,443 --dpi-desync=disorder2 --dpi-desync-split-pos=1
echo [+] Активно. Проверяй YouTube.
pause
goto MENU

:RUN_DIS_SEQ
call :PREPARE
echo [*] Запуск: Disorder Sequence Overlay...
start /b winws.exe --wf-l3=ipv4 --wf-tcp=80,443 --dpi-desync=disorder2 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl=1
echo [+] Активно.
pause
goto MENU

:RUN_DIS_TTL
call :PREPARE
echo [*] Запуск: Disorder + Auto-TTL...
start /b winws.exe --wf-l3=ipv4 --wf-tcp=80,443 --dpi-desync=disorder2 --dpi-desync-split-pos=1 --dpi-desync-autottl=2
echo [+] Активно.
pause
goto MENU

:PREPARE
taskkill /f /im winws.exe >nul 2>&1
ipconfig /flushdns >nul
exit /b

:STOP
taskkill /f /im winws.exe >nul 2>&1
echo [!] Процессы остановлены.
pause
goto MENU