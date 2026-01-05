@echo off
set PROXY_HOST=host.docker.internal
set PROXY_PORT=7890

set http_proxy=socks5://%PROXY_HOST%:%PROXY_PORT%
set HTTP_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%
set https_proxy=socks5://%PROXY_HOST%:%PROXY_PORT%
set HTTPS_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%
set ftp_proxy=socks5://%PROXY_HOST%:%PROXY_PORT%
set FTP_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%
set all_proxy=socks5://%PROXY_HOST%:%PROXY_PORT%
set ALL_PROXY=socks5://%PROXY_HOST%:%PROXY_PORT%

set no_proxy=localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;<local>
set NO_PROXY=localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;<local>
