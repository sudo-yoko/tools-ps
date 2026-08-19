$port = 8000
$url = "http://localhost:${port}/"

# HTTPリスナーの開始
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Output "Webサーバーを開始しました: $url"
Write-Output "終了するには ${url}stop にアクセスしてください。"

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8';
    '.css'  = 'text/css; charset=utf-8';
    '.js'   = 'application/javascript; charset=utf-8';
    '.png'  = 'image/png';
    '.svg'  = 'image/svg+xml';
}

# 自動的にブラウザで開く
Start-Process $url

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        if ($request.url.AbsolutePath -eq '/stop') {
            $message = [System.Text.Encoding]::UTF8.GetBytes("Server stopped.")
            $response.ContentType = 'text/plain; charset=utf-8'
            $response.OutputStream.Write($message, 0, $message.Length)
            $response.Close()
            break;
        }

        $relativePath = $request.Url.AbsolutePath.TrimStart('/').Replace('/', '\')
        $filePath = Join-Path $PSScriptRoot $relativePath

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()

            $response.StatusCode = 200
            $response.ContentLength64 = $bytes.Length
            $contentType = $mimeTypes[$ext]
            if (-not $contentType) {
                Write-Warning "MIMEタイプが未定義です: '$ext'"
            }
            $response.ContentType = $contentType
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
}
finally {
    $listener.Stop()
    Write-Output "Webサーバーを停止しました: $url"
}