@echo off
title AlexDPI v4.0 SAFE-MODE
chcp 65001 >nul
cd /d "%~dp0"

:: Проверка прав
net session >nul 2>&1
if %errorLevel% neq 0 (echo [!] Запусти от Админа! & pause & exit)

:MENU
cls
echo ========================================================
echo               ALEX-DPI: SAFE RECOVERY
echo ========================================================
echo   Если интернет пропал - просто закрой это окно.
echo.
echo   1) ЗАПУСТИТЬ БЕЗОПАСНЫЙ РЕЖИМ (Метод: Split Only)
echo      - Самый стабильный. Не должен ломать сеть.
echo.
echo   2) ЗАПУСТИТЬ ПРОДВИНУТЫЙ (Метод: Disorder)
echo      - Если первый не помог с YouTube.
echo.
echo   3) ПОЛНЫЙ СБРОС (Если интернет не появился)
echo   4) ВЫХОД
echo ========================================================
set /p opt="Выбор: "

if "%opt%"=="1" goto RUN_SAFE
if "%opt%"=="2" goto RUN_DISORDER
if "%opt%"=="3" goto RESET_NET
if "%opt%"=="4" exit
goto MENU

:RUN_SAFE
taskkill /f /im winws.exe >nul 2>&1
echo [*] Запуск Safe Mode...
:: Используем только split2 на 2 байта. Это минимальное вмешательство.
start /b winws.exe --wf-l3=ipv4 --wf-tcp=80,443 --dpi-desync=split2 --dpi-desync-split-pos=2
echo [+] Работает. Проверяй сайты.
pause
goto MENU

:RUN_DISORDER
taskkill /f /im winws.exe >nul 2>&1
echo [*] Запуск Disorder Mode...
:: Перемешивание пакетов без изменения их структуры.
start /b winws.exe --wf-l3=ipv4 --wf-tcp=80,443 --dpi-desync=disorder2 --dpi-desync-split-pos=1
echo [+] Работает.
pause
goto MENU

:RESET_NET
taskkill /f /im winws.exe >nul 2>&1
echo [*] Сброс сетевых фильтров...
netsh int ip reset
netsh winsock reset
echo [OK] Готово. Если интернета нет - перезагрузи ПК.
pause
goto MENU