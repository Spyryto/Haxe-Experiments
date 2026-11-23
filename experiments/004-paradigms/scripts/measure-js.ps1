$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path dist/004-js | Out-Null
$results = @()
$names = @("inheritance", "composition", "fp")
$modes = @("full", "no", "kept")
foreach ($name in $names) {
    foreach ($mode in $modes) {
        $file = "dist/004-js/$name-$mode.js"
        $dce = if ($mode -eq "no") { "no" } else { "full" }
        $args = @(
            "-cp", "experiments/004-paradigms/shared",
            "-cp", "experiments/004-paradigms/$name",
            "-main", "Main",
            "-lib", "hxnodejs",
            "-dce", $dce,
            "-js", $file
        )
        if ($mode -eq "kept") { $args += @("-D", "keep_gorilla") }
        $clock = [Diagnostics.Stopwatch]::StartNew()
        & haxe @args
        $clock.Stop()
        if ($LASTEXITCODE -ne 0) { throw "Haxe JS compile error: $name/$mode" }
        $output = (& node $file | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { throw "JS runtime error: $name/$mode" }
        if ($output -ne "checksum=1508812") { throw "Wrong output $name/$mode : $output" }
        $contents = [IO.File]::ReadAllText((Resolve-Path $file))
        $sentinel = $contents.Contains("JUNGLE_SENTINEL_")
        if ($mode -eq "kept" -and -not $sentinel) { throw "Forced reachable gorilla missing: $name" }
        $results += [ordered]@{
            variant = $name
            mode = $mode
            haxe_dce = $dce
            gorilla_accessible = ($mode -eq "kept")
            bytes = [int64](Get-Item $file).Length
            has_jungle_sentinel = $sentinel
            compile_ms = [math]::Round($clock.Elapsed.TotalMilliseconds, 2)
            output = $output
        }
    }
}
$results | ConvertTo-Json -Depth 5 | Set-Content dist/004-js/measurements.json
$results | Format-Table -AutoSize | Out-String | Write-Host
if ($env:GITHUB_STEP_SUMMARY) {
    "### Haxe JavaScript paradigms and dead-code elimination" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    "| Model | DCE | JS bytes | Jungle sentinel present |" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    "|---|---|---:|---|" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    foreach ($x in $results) {
        "| $($x.variant) | $($x.mode) | $($x.bytes) | $($x.has_jungle_sentinel) |" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    }
}
