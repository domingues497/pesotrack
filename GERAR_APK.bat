@echo off
setlocal

cd /d "%~dp0"

echo ==========================================
echo PesoTrack - Geracao automatica de APK
echo ==========================================
echo.

echo [1/4] Baixando dependencias...
call flutter pub get
if errorlevel 1 goto :erro

echo.
echo [2/4] Analisando projeto...
call flutter analyze
if errorlevel 1 goto :erro

echo.
echo [3/4] Rodando testes...
call flutter test
if errorlevel 1 goto :erro

echo.
echo [4/4] Gerando APK de release...
call flutter build apk --release
if errorlevel 1 goto :erro

echo.
echo APK gerado com sucesso:
echo build\app\outputs\flutter-apk\app-release.apk
pause
exit /b 0

:erro
echo.
echo O processo falhou. Revise as mensagens acima.
pause
exit /b 1
