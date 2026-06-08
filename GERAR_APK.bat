@echo off
color 0A
title Configurador de Rede CAPAL (Admin)

:: ===============================
:: USUARIO ADMINISTRADOR
:: ===============================

set USUARIO=CAPAL\rafael.domingues

:: ===============================
:: MENU
:: ===============================

:MENU
cls
echo =========================================
echo      CONFIGURADOR DE REDE CAPAL
echo =========================================
echo.
echo Usuario logado: %USERDOMAIN%\%USERNAME%
echo Computador: %COMPUTERNAME%
echo.
echo Escolha a unidade:
echo 1 - CLP  (192.168.4.46 / 255.255.255.0 / 192.168.4.1)
echo 2 - IBA  (192.168.13.28 / 255.255.255.0 / 192.168.13.1)
echo 3 - JQT  (192.168.8.36 / 255.255.255.0 / 192.168.8.1)
echo 4 - STO  (192.168.23.58 / 255.255.255.0 / 192.168.23.1)
echo 5 - PGR  (192.168.25.4 / 255.255.255.0 / 192.168.25.1)
echo.
set /p OPCAO=Digite a opcao desejada: 

:: ===============================
:: DEFINICAO DOS IPS
:: ===============================

if "%OPCAO%"=="1" (
    set UNIDADE=CLP
    set IP=192.168.4.46
    set MASCARA=255.255.255.0
    set GATEWAY=192.168.4.1
)

if "%OPCAO%"=="2" (
    set UNIDADE=IBA
    set IP=192.168.13.28
    set MASCARA=255.255.255.0
    set GATEWAY=192.168.13.1
)

if "%OPCAO%"=="3" (
    set UNIDADE=JQT
    set IP=192.168.8.36
    set MASCARA=255.255.255.0
    set GATEWAY=192.168.8.1
)

if "%OPCAO%"=="4" (
    set UNIDADE=STO
    set IP=192.168.23.58
    set MASCARA=255.255.255.0
    set GATEWAY=192.168.23.1
)

if "%OPCAO%"=="5 (
    set UNIDADE=PGR
    set IP=192.168.25.4
    set MASCARA=255.255.255.0
    set GATEWAY=192.168.25.1
)

:: ===============================
:: VALIDACAO
:: ===============================

if not defined UNIDADE (
    echo.
    echo Opcao invalida!
    timeout /t 2 >nul
    goto MENU
)

:: ===============================
:: CRIA SCRIPT TEMPORARIO (ADMIN)
:: ===============================

set TEMPBAT=%temp%\config_ip_admin.bat

echo @echo off > "%TEMPBAT%"
echo color 0B >> "%TEMPBAT%"
echo title Configurando Rede - %UNIDADE% >> "%TEMPBAT%"
echo set INTERFACE=Rede >> "%TEMPBAT%"

echo echo ===================================== >> "%TEMPBAT%"
echo echo CONFIGURANDO %UNIDADE% >> "%TEMPBAT%"
echo echo ===================================== >> "%TEMPBAT%"
echo. >> "%TEMPBAT%"

echo netsh interface ip set address name^="%%INTERFACE%%" static %IP% %MASCARA% %GATEWAY% 1 >> "%TEMPBAT%"
echo netsh interface ip set dns name^="%%INTERFACE%%" static 192.168.1.231 >> "%TEMPBAT%"
echo netsh interface ip add dns name^="%%INTERFACE%%" 8.8.8.8 index^=2 >> "%TEMPBAT%"

echo echo. >> "%TEMPBAT%"
echo echo Configuracao aplicada. >> "%TEMPBAT%"
echo echo. >> "%TEMPBAT%"
echo ipconfig >> "%TEMPBAT%"
echo echo. >> "%TEMPBAT%"
echo pause >> "%TEMPBAT%"

:: ===============================
:: EXECUTA COMO ADMIN (SAVE CRED)
:: ===============================

runas /savecred /user:%USUARIO% "%TEMPBAT%"

exit