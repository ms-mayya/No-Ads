# Proxy configuration
$Global:PROXY_HOST = "host.docker.internal"
$Global:PROXY_PORT = "7890"
$Global:PROXY_NO = "localhost;127.*;192.168.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;<local>"

function Global:proxy-on {
    $proxyUrl = "socks5://${Global:PROXY_HOST}:${Global:PROXY_PORT}"
    @('http_proxy', 'HTTP_PROXY', 'https_proxy', 'HTTPS_PROXY', 'ftp_proxy', 'FTP_PROXY', 'all_proxy', 'ALL_PROXY') | ForEach-Object {
        Set-Item "Env:\$_" $proxyUrl
    }
    $env:no_proxy = $Global:PROXY_NO
    $env:NO_PROXY = $Global:PROXY_NO
    Write-Host "✓ Proxy enabled: $proxyUrl" -ForegroundColor Green
}

function Global:proxy-off {
    @('http_proxy', 'HTTP_PROXY', 'https_proxy', 'HTTPS_PROXY', 'ftp_proxy', 'FTP_PROXY', 'all_proxy', 'ALL_PROXY', 'no_proxy', 'NO_PROXY') | ForEach-Object {
        Remove-Item "Env:\$_" -ErrorAction SilentlyContinue
    }
    Write-Host "✓ Proxy disabled" -ForegroundColor Yellow
}

function Global:proxy-status {
    if ($env:all_proxy) {
        Write-Host "✓ Proxy is ON: $($env:all_proxy)" -ForegroundColor Green
    } else {
        Write-Host "✗ Proxy is OFF" -ForegroundColor Red
    }
}
