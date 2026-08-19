$port = 8000
$url = "http://localhost:${port}/"

# HTTPリスナーの開始
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Output "Webサーバーを開始しました: $url"
Write-Output "終了するには Ctrl + C を押してください。"

# 自動的にブラウザで開く
Start-Process $url

$path = Join-Path $PSScriptRoot "dummy-web-form.html"
$bytes = [System.IO.File]::ReadAllBytes($path)

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $response = $context.Response

        $response.StatusCode = 200
        $response.ContentLength64 = $bytes.Length
        $response.ContentType = "text/html; charset=utf-8"
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.Close()
    }
}
finally {
    $listener.Stop()
}