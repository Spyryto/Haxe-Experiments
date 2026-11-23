$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force dist/hxwidgets-direct | Out-Null

$exe = Get-ChildItem -Path build/hxwidgets-direct -Recurse -Filter 'Main.exe' -File | Select-Object -First 1
if ($null -eq $exe) { throw "Direct hxWidgets Main.exe missing" }

$target = Join-Path (Resolve-Path dist/hxwidgets-direct).Path 'hxWidgets-Direct.exe'
Copy-Item -LiteralPath $exe.FullName -Destination $target

$dlls = @(Get-ChildItem -LiteralPath $exe.DirectoryName -Filter '*.dll' -File)
foreach ($dll in $dlls) { Copy-Item -LiteralPath $dll.FullName -Destination dist/hxwidgets-direct }

$directBytes = [int64](Get-Item -LiteralPath $target).Length
$uiExe = Get-Item -LiteralPath dist/wxwidgets/HaxeUI-Windows.exe
$uiBytes = [int64]$uiExe.Length
$cliExe = Get-ChildItem -Path build/cli -Recurse -Filter Main.exe -File | Select-Object -First 1
if ($null -eq $cliExe) { throw "CLI baseline Main.exe missing" }
$cliBytes = [int64]$cliExe.Length
$ratio = [math]::Round($uiBytes / $directBytes, 3)
$directVsCli = [math]::Round($directBytes / $cliBytes, 3)

$deps = & dumpbin.exe /dependents $target | Out-String
if ($LASTEXITCODE -ne 0) { throw "dumpbin failed" }
Set-Content -Path dist/hxwidgets-direct/dependencies.txt -Value $deps

$startup = $null
$memory = $null
$windowSeen = $false
$processAlive = $false
$process = $null
try {
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $process = Start-Process -FilePath $target -WorkingDirectory (Resolve-Path dist/hxwidgets-direct).Path -PassThru
    for ($i = 0; $i -lt 100; $i++) {
        Start-Sleep -Milliseconds 100
        $process.Refresh()
        if ($process.HasExited) { throw "Direct GUI terminated prematurely: $($process.ExitCode)" }
        if ($process.MainWindowHandle -ne [IntPtr]::Zero) {
            $startup = [int]$clock.ElapsedMilliseconds
            $windowSeen = $true
            break
        }
    }
    Start-Sleep -Seconds 2
    $process.Refresh()
    if ($process.HasExited) { throw "Direct GUI terminated during smoke test: $($process.ExitCode)" }
    $processAlive = $true
    $memory = [int64]$process.WorkingSet64
} finally {
    if ($null -ne $process) {
        $process.Refresh()
        if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue }
        $process.Dispose()
    }
}

$shipped = @(Get-ChildItem -LiteralPath dist/hxwidgets-direct -File)
$shippedBytes = [int64](($shipped | Measure-Object -Property Length -Sum).Sum)
$result = [ordered]@{
    platform = "windows-x64"
    haxe = "4.3.7"
    hxcpp = "4.3.2"
    hxwidgets = "1.12.0"
    wxwidgets = "3.1.3"
    wx_linkage = "static"
    direct_executable_bytes = $directBytes
    haxeui_executable_bytes = $uiBytes
    cli_executable_bytes = $cliBytes
    haxeui_to_direct_size_ratio = $ratio
    direct_to_cli_size_ratio = $directVsCli
    adjacent_dll_count = $dlls.Count
    shipped_files_bytes = $shippedBytes
    window_observed = $windowSeen
    startup_to_window_ms_ci = $startup
    working_set_bytes_ci = $memory
    smoke_process_alive = $processAlive
}
$json = $result | ConvertTo-Json -Depth 4
Set-Content -Path dist/hxwidgets-direct/measurements.json -Value $json
Write-Host $json
if ($env:GITHUB_STEP_SUMMARY) {
    @(
        "### Compare GUI backends — Windows x64 (same runner)"
        "| Metric | CLI 000 | HaxeUI 002 | hxWidgets direct 003 |"
        "|---|---:|---:|---:|"
        "| EXE bytes | $cliBytes | $uiBytes | $directBytes |"
        "| HaxeUI/direct size | — | ${ratio}x | reference |"
        "| Direct/CLI size | reference | — | ${directVsCli}x |"
        "| Direct first window (CI ms) | — | see other metrics | $(if ($null -ne $startup) { $startup } else { 'not observed' }) |"
        "| Direct RAM working set (CI bytes) | — | see other metrics | $memory |"
        "| Direct window detected | — | see other metrics | $windowSeen |"
    ) | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
}
