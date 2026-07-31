$root = Resolve-Path (Join-Path $PSScriptRoot '..\src\NetFramework4App')
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add('http://127.0.0.1:8080/')
$listener.Start()
Write-Host "Listening on http://127.0.0.1:8080/"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $response = $context.Response
    $path = $context.Request.Url.AbsolutePath
    $fileName = 'index.html'
    if ($path -and $path -ne '/') {
        $fileName = $path.TrimStart('/')
    }

    $fullPath = Join-Path $root $fileName
    if (-not (Test-Path $fullPath)) {
        $fullPath = Join-Path $root 'index.html'
    }

    $bytes = [System.IO.File]::ReadAllBytes($fullPath)
    $response.ContentType = if ($fullPath.EndsWith('.css')) { 'text/css' } else { 'text/html' }
    $response.ContentLength64 = $bytes.Length
    $output = $response.OutputStream
    $output.Write($bytes, 0, $bytes.Length)
    $output.Close()
    $response.Close()
}
