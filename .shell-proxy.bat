@echo off

set PROXY_HOST=host.docker.internal
set PROXY_PORT=7890
set "PROXY_NO=localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;^<local^>"

if "%1"=="on" goto enable
if "%1"=="off" goto disable
if "%1"=="status" goto status
goto help

:enable
set PROXY_URL=socks5://%PROXY_HOST%:%PROXY_PORT%
set http_proxy=%PROXY_URL%
set HTTP_PROXY=%PROXY_URL%
set https_proxy=%PROXY_URL%
set HTTPS_PROXY=%PROXY_URL%
set ftp_proxy=%PROXY_URL%
set FTP_PROXY=%PROXY_URL%
set all_proxy=%PROXY_URL%
set ALL_PROXY=%PROXY_URL%
set "no_proxy=%PROXY_NO%"
set "NO_PROXY=%PROXY_NO%"
echo Proxy enabled: %PROXY_URL%
goto end

:disable
set http_proxy=
set HTTP_PROXY=
set https_proxy=
set HTTPS_PROXY=
set ftp_proxy=
set FTP_PROXY=
set all_proxy=
set ALL_PROXY=
set no_proxy=
set NO_PROXY=
echo Proxy disabled
goto end

:status
if "%all_proxy%"=="" (
    echo Proxy is OFF
) else (
    echo Proxy is ON: %all_proxy%
)
goto end

:help
echo Usage: .shell-proxy.bat [on^|off^|status]
echo   on      - Enable proxy
echo   off     - Disable proxy
echo   status  - Show proxy status

:end
