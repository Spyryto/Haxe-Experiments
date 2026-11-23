# Executed from the repository root after successful wxWidgets and hxcpp builds.
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force dist/wxwidgets | Out-Null

$exe = Get-ChildItem -Path build/haxeui-wxwidgets -Recurse -Filter 'Main.exe' -File | Select-Object -First 1
if ($null -eq $exe) { throw "Main.exe was not generated" }

$target = Join-Path (Resolve-Path dist/wxwidgets).Path 'HaxeUI-Windows.exe'
Copy-Item -LiteralPath $exe.FullName -Destination $target

# Also stage any files that must be shipped next to the executable.
$dlls = @(Get-ChildItem -LiteralPath $exe.DirectoryName -Filter '*.dll' -File)
foreach($dll in $dlls) { Copy-Item -LiteralPath $dll.FullName -Destination dist/wxwidgets }

$bytes = (Get-Item -LiteralPath $target).Length
$cli = Get-ChildItem -Path build/cli -Recurse -Filter 'Main.exe' -File | Select-Object -First 1
if ($null -eq $cli) { throw "CLI baseline executable is missing" }
$cliBytes = [int64]$cli.Length
$guiVsCli = [math]::Round($bytes / $cliBytes, 2)
$shipped = @(Get-ChildItem -LiteralPath dist/wxwidgets -File)
$packageBytes = ($shipped | Measure-Object -Property Length -Sum).Sum
if ($null -eq $packageBytes) { $packageBytes = 0 }

$dependencies = & dumpbin.exe /dependents $target | Out-String
if ($LASTEXITCODE -ne 0) { throw "dumpbin failed" }
Set-Content -Path dist/wxwidgets/dependencies.txt -Value $dependencies

# Windows CI may not have an interactive desktop, so a native GUI isn't fully testable here.
$startup = $null
$memory = $null
$windowSeen = $false
$stillRunning = $false
$process = $null
try {
    $clock = [System.Diagnostics.Stopwatch]::StartNew()
    $process = Start-Process -FilePath $target -WorkingDirectory (Resolve-Path dist/wxwidgets).Path -PassThru
    for ($i=0; $i -lt 100; $i++) {
        Start-Sleep -Milliseconds 100
        $process.Refresh()
        if ($process.HasExited) { throw "Native GUI exited unexpectedly with code $($process.ExitCode)" }
        if ($process.MainWindowHandle -ne [IntPtr]::Zero) {
            $startup = [int]$clock.ElapsedMilliseconds
            $windowSeen = $true
            break
        }
    }
    Start-Sleep -Seconds 2
    $process.Refresh()
    if ($process.HasExited) { throw "Native GUI exited during the smoke test with code $($process.ExitCode)" }
    $stillRunning = $true
    $memory = [int64]$process.WorkingSet64
} finally {
    if ($null -ne $process) {
        $process.Refresh()
        if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue }
        $process.Dispose()
    }
}

$result = [ordered]@{
  platform = "windows-x64"
  haxe = "4.3.7"
  haxeui = "1.7.0"
  hxwidgets = "1.12.0"
  wxwidgets = "3.1.3"
  wx_linkage = "static"
  executable_bytes = [int64]$bytes
  cli_baseline_bytes = $cliBytes
  gui_to_cli_executable_size_ratio = $guiVsCli
  shipped_files_bytes = [int64]$packageBytes
  adjacent_dll_count = $dlls.Count
  window_observed = $windowSeen
  startup_to_window_ms_ci = $startup
  working_set_bytes_ci = $memory
  smoke_process_alive = $stillRunning
}
$json = $result | ConvertTo-Json -Depth 4
Set-Content -Path dist/wxwidgets/measurements.json -Value $json
Write-Host $json
if ($env:GITHUB_STEP_SUMMARY) {
  @(
    "### HaxeUI + wxWidgets native x64"
    "| Metrica | Valore |"
    "|---|---:|"
    "| EXE (byte) | $bytes |"
    "| CLI baseline EXE (byte) | $cliBytes |"
    "| Dimensioni GUI / baseline | ${guiVsCli}x |"
    "| Pacchetto (byte) | $packageBytes |"
    "| DLL affiancate | $($dlls.Count) |"
    "| Processo vivo dopo 2 sec | $stillRunning |"
    "| Finestra visibile al runner | $windowSeen |"
    "| Avvio → finestra (ms CI) | $(if ($null -ne $startup) { $startup } else { 'non osservabile' }) |"
    "| RAM / working set (byte CI) | $memory |"
  ) | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
}
