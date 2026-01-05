$PROXY_HOST = "host.docker.internal"
$PROXY_PORT = "7890"

$env:http_proxy = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:HTTP_PROXY = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:https_proxy = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:HTTPS_PROXY = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:ftp_proxy = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:FTP_PROXY = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:all_proxy = "socks5://${PROXY_HOST}:${PROXY_PORT}"
$env:ALL_PROXY = "socks5://${PROXY_HOST}:${PROXY_PORT}"

$env:no_proxy = "localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;<local>"
$env:NO_PROXY = "localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;<local>"
