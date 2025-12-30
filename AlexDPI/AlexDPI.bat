@echo off
title AlexDPI v4.3 - Speed Edition
chcp 65001 >nul
cd /d "%~dp0"

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (echo [!] Запусти от Админа! & pause & exit)

:MENU
cls
echo ========================================================
echo               ALEX-DPI: SPEED OPTIMIZED
echo ========================================================
echo.
echo  1) FAST-SPLIT: Минимальные задержки (Split2)
echo  2) DISORDER: Стандартная и наиболее стабильная стратегия
echo  3) FAST-FAKE: Быстрая подмена (TTL 7)
echo  4) SMART-TTL: Оптимальный пробив ТСПУ
echo  5) FAST-MIX: Скоростной Disorder + Hostcase
echo  6) LIGHT-HYBRID: Облегченный гибрид
echo  7) MAX-STRIKE: Полный пробив (Fast Mode)
echo.
echo  0) ПОЛНАЯ ОСТАНОВКА (Выгрузить всё)
echo  R) СБРОС СЕТИ И КЭША
echo  E) ВЫХОД
echo ========================================================
set "ARGS="
set /p opt="Выбор (1-7): "

:: Оптимизированные стратегии для скорости (меньше лишних байтов)
if "%opt%"=="1" set "ARGS=--dpi-desync=split2 --dpi-desync-split-pos=1"
if "%opt%"=="2" set "ARGS=--dpi-desync=disorder2 --dpi-desync-split-pos=1"
if "%opt%"=="3" set "ARGS=--dpi-desync=fake --dpi-desync-ttl=7 --dpi-desync-repeats=1"
if "%opt%"=="4" set "ARGS=--dpi-desync=split2 --dpi-desync-autottl=5"
if "%opt%"=="5" set "ARGS=--dpi-desync=disorder2 --dpi-desync-split-pos=1 --hostcase"
if "%opt%"=="6" set "ARGS=--dpi-desync=split --dpi-desync-split-pos=method --dpi-desync-fake-http=0x00"
if "%opt%"=="7" set "ARGS=--dpi-desync=fake,disorder2 --dpi-desync-split-pos=1 --dpi-desync-ttl=10 --dpi-desync-fooling=badsum"

if "%opt%"=="0" goto STOP_ALL
if /i "%opt%"=="r" goto RESET_NET
if /i "%opt%"=="e" goto EXIT_PROG
if defined ARGS goto RUN
goto MENU

:RUN
call :KILL_PROC
echo [*] Запуск: Оптимизация потока...

if exist "list.txt" (
    set "LIST_ARG=--hostlist=list.txt"
    echo [+] Фильтрация включена (list.txt)
) else (
    set "LIST_ARG="
    echo [!] list.txt не найден. Режим Global Speed.
)

:: Запуск с низким приоритетом для экономии ресурсов, но быстрой обработкой пакетов
start /b /low "" winws.exe --wf-l3=ipv4 --wf-tcp=80,443 %LIST_ARG% %ARGS%
echo [+] Работает.
timeout /t 2 >nul
goto MENU

:STOP_ALL
call :KILL_PROC
echo [OK] Все компоненты и драйверы удалены.
pause
goto MENU

:RESET_NET
call :KILL_PROC
echo [*] Сброс кэша и интерфейсов...
ipconfig /flushdns >nul
netsh winsock reset >nul
echo [OK] Готово.
pause
goto MENU

:EXIT_PROG
call :KILL_PROC
exit

:KILL_PROC
echo [*] Деактивация обхода...
:: 1. Убиваем процесс
taskkill /f /t /im winws.exe >nul 2>&1

:: 2. Принудительная выгрузка драйвера (остановка фильтрации)
sc stop WinDivert >nul 2>&1
sc stop WinDivert1.4 >nul 2>&1
sc delete WinDivert >nul 2>&1
sc delete WinDivert1.4 >nul 2>&1

:: 3. Очистка временных файлов, чтобы драйвер не висел в системе
if exist "%SystemRoot%\System32\Drivers\WinDivert64.sys" del /q /f "%SystemRoot%\System32\Drivers\WinDivert64.sys" >nul 2>&1
if exist "%SystemRoot%\System32\Drivers\WinDivert.sys" del /q /f "%SystemRoot%\System32\Drivers\WinDivert.sys" >nul 2>&1

:: 4. Закрытие "зомби" соединений (чтобы YouTube сразу понял, что всё кончено)
netsh interface ip delete arpcache >nul 2>&1
exit /b
