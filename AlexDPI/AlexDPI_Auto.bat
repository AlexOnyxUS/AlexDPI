@echo off
title AlexDPI v4.2 - Multi-Strategy Edition
chcp 65001 >nul
cd /d "%~dp0"

:: Проверка прав
net session >nul 2>&1
if %errorLevel% neq 0 (echo [!] Запусти от Админа! & pause & exit)

:MENU
cls
echo ========================================================
echo                ALEX-DPI: 7 СТРАТЕГИЙ ОБХОДА
echo ========================================================
echo  Используется список: list.txt (должен быть рядом)
echo.
echo  1) SAFE: Split2 (Минимальный риск)
echo  2) ADVANCED: Disorder (Стандарт)
echo  3) FAKE: Fake Packet (Подмена данных)
echo  4) TTL: Auto TTL (Обход через время жизни пакета)
echo  5) MIX: Disorder + No-Frag (Смешанный)
echo  6) HYBRID: Split + Fake (Для сложных блокировок)
echo  7) EXTREME: All-In-One (Максимальный пробив)
echo.
echo  0) ОСТАНОВИТЬ ВСЁ И СБРОСИТЬ СЕТЬ
echo  E) ВЫХОД
echo ========================================================
set /p opt="Выбор стратегии: "

if "%opt%"=="1" set "ARGS=--dpi-desync=split2 --dpi-desync-split-pos=2"
if "%opt%"=="2" set "ARGS=--dpi-desync=disorder2 --dpi-desync-split-pos=1"
if "%opt%"=="3" set "ARGS=--dpi-desync=fake --dpi-desync-ttl=5"
if "%opt%"=="4" set "ARGS=--dpi-desync=split2 --dpi-desync-autottl=2"
if "%opt%"=="5" set "ARGS=--dpi-desync=disorder2 --dpi-desync-split-pos=2 --hostcase"
if "%opt%"=="6" set "ARGS=--dpi-desync=split2 --dpi-desync-split-pos=mame --dpi-desync-fake-http=0x00000000"
if "%opt%"=="7" set "ARGS=--dpi-desync=fake,disorder2 --dpi-desync-split-pos=1 --dpi-desync-ttl=11"

if "%opt%"=="0" goto RESET_NET
if /i "%opt%"=="e" goto EXIT_PROG
if defined ARGS goto RUN

goto MENU

:RUN
call :KILL_PROC
echo [*] Запуск выбранной стратегии...
:: Проверяем наличие файла со списком
if exist "list.txt" (
    set "LIST_ARG=--hostlist=list.txt"
    echo [+] Использую список доменов из list.txt
) else (
    set "LIST_ARG="
    echo [!] list.txt не найден. Применяю ко всему трафику!
)

start /b "" winws.exe --wf-l3=ipv4 --wf-tcp=80,443 %LIST_ARG% %ARGS%
echo [+] Процесс запущен в фоне.
pause
goto MENU

:RESET_NET
call :KILL_PROC
netsh int ip reset >nul
netsh winsock reset >nul
echo [OK] Все процессы убиты, сетевые настройки сброшены.
pause
goto MENU

:EXIT_PROG
call :KILL_PROC
exit

:KILL_PROC
taskkill /f /t /im winws.exe >nul 2>&1
exit /b
