@echo off
setlocal enabledelayedexpansion

set PROXY_HOST=host.docker.internal
set PROXY_PORT=7890
set PROXY_NO=localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;^<local^>

if "%1"=="on" goto :enable
if "%1"=="off" goto :disable
if "%1"=="status" goto :status
goto :help

:enable
set PROXY_URL=socks5://%PROXY_HOST%:%PROXY_PORT%
for %%p in (http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY all_proxy ALL_PROXY) do set %%p=%PROXY_URL%
set no_proxy=%PROXY_NO%
set NO_PROXY=%PROXY_NO%
echo [92m✓ Proxy enabled: %PROXY_URL%[0m
goto :end

:disable
for %%p in (http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY) do set %%p=
echo [93m✓ Proxy disabled[0m
goto :end

:status
if defined all_proxy (
    echo [92m✓ Proxy is ON: %all_proxy%[0m
) else (
    echo [91m✗ Proxy is OFF[0m
)
goto :end

:help
echo Usage: proxy [on^|off^|status]
echo   on      - Enable proxy
echo   off     - Disable proxy
echo   status  - Show proxy status

:end
endlocal & (
    for %%p in (http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy FTP_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY) do set %%p=%!%%p!%
)
