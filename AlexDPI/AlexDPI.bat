@echo off
title AlexDPI v8.0 - Working Version
chcp 65001 >nul
cd /d "%~dp0"

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Запустите файл от имени Администратора!
    pause
    exit
)

:: Проверка наличия winws.exe
if not exist "winws.exe" (
    echo [X] Ошибка: winws.exe не найден!
    echo.
    echo Инструкция:
    echo 1. Скачайте с https://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip
    echo 2. Распакуйте архив
    echo 3. Скопируйте winws.exe в папку с этим файлом
    pause
    exit
)

:MENU
cls
echo ========================================================
echo         ALEX-DPI v8.0 - ПРОСТЫЕ РАБОЧИЕ СТРАТЕГИИ
echo ========================================================
echo.
echo.
echo  1) Базовый split2 (должен работать везде)
echo  2) Базовый disorder2
echo  3) Fake с TTL (если 1-2 не работают)
echo  4) Комбинация split2 + fake
echo  5) Полный пробив (multidisorder)
echo.
echo  0) ПОЛНАЯ ОСТАНОВКА
echo  R) СБРОС СЕТИ
echo  E) ВЫХОД
echo ========================================================
set /p opt="Выберите (1-5, 0, R, E): "

:: Простые рабочие параметры из официальной документации [citation:1]
if "%opt%"=="1" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --dpi-desync=split2 --dpi-desync-split-pos=1"
if "%opt%"=="2" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --dpi-desync=disorder2"
if "%opt%"=="3" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --dpi-desync=fake --dpi-desync-ttl=7"
if "%opt%"=="4" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --dpi-desync=fake,split2 --dpi-desync-split-pos=1 --dpi-desync-ttl=7"
if "%opt%"=="5" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --dpi-desync=multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=6"

if "%opt%"=="0" goto STOP_ALL
if /i "%opt%"=="r" goto RESET_NET
if /i "%opt%"=="e" goto EXIT_PROG
if defined ARGS goto RUN
goto MENU

:RUN
cls
echo ========================================================
echo                    ЗАПУСК
echo ========================================================
echo.
echo Останавливаем предыдущие процессы...
taskkill /f /im winws.exe >nul 2>&1
timeout /t 2 >nul

echo Запускаем стратегию %opt%...
echo Параметры: %ARGS%
echo.

:: Запуск без фона чтобы видеть ошибки
winws.exe %ARGS%

:: Эта строка выполнится только когда закроется winws
echo.
echo [i] Программа завершена. Нажмите любую клавишу...
pause >nul
goto MENU

:STOP_ALL
taskkill /f /im winws.exe >nul 2>&1
sc stop WinDivert >nul 2>&1
sc stop WinDivert1.4 >nul 2>&1
echo [OK] Остановлено
timeout /t 2 >nul
goto MENU

:RESET_NET
ipconfig /flushdns
netsh winsock reset
echo [OK] Сброс выполнен. Рекомендуется перезагрузить ПК.
pause
goto MENU

:EXIT_PROG
taskkill /f /im winws.exe >nul 2>&1
exit
