$port = 8000
$url = "http://localhost:${port}/"

# HTTPリスナーの開始
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Output "Webサーバーを開始しました: $url"
Write-Output "終了するには Ctrl + C を押してください。"

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8';
    '.css'  = 'test/css; charset=utf-8';
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

        $relativePath = $request.Url.AbsolutePath.TrimStart('/').Replace('/', '\')
        $filePath = Join-Path $PSScriptRoot $relativePath

        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()

            $response.StatusCode = 200
            $response.ContentLength64 = $bytes.Length

            $contentType = ''
            if ($mimeTypes.ContainsKey($ext)) {
                $contentType = $mimeTypes[$ext]
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
}