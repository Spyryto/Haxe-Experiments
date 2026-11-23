$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path dist/004-cpp | Out-Null
$results = @()
foreach ($name in @("inheritance", "composition", "fp")) {
    foreach ($mode in @("full", "no", "kept")) {
        if ($mode -eq "kept" -and $name -ne "inheritance") { continue }
        $folder = "build/004-$name-$mode"
        $dce = if ($mode -eq "no") { "no" } else { "full" }
        $args = @(
            "-cp", "experiments/004-paradigms/shared",
            "-cp", "experiments/004-paradigms/$name",
            "-main", "Main",
            "-dce", $dce,
            "-D", "ABI=-MD",
            "-D", "HXCPP_M64",
            "-cpp", $folder
        )
        if ($mode -eq "kept") { $args += @("-D", "keep_gorilla") }
        $clock = [Diagnostics.Stopwatch]::StartNew()
        & haxe @args
        $clock.Stop()
        if ($LASTEXITCODE -ne 0) { throw "Haxe hxcpp compilation failed: $name/$mode" }
        $exe = Get-ChildItem -Path $folder -Recurse -File -Filter Main.exe | Select-Object -First 1
        if ($null -eq $exe) { throw "No Main.exe for $name/$mode" }
        $output = (& $exe.FullName | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { throw "Native program failed: $name/$mode" }
        if ($output -ne "checksum=1508812") { throw "Wrong native output $name/$mode : $output" }
        $results += [ordered]@{
            variant = $name
            mode = $mode
            haxe_dce = $dce
            gorilla_accessible = ($mode -eq "kept")
            executable_bytes = [int64]$exe.Length
            compile_seconds = [math]::Round($clock.Elapsed.TotalSeconds, 2)
            output = $output
        }
    }
}
$results | ConvertTo-Json -Depth 5 | Set-Content dist/004-cpp/measurements.json
$results | Format-Table -AutoSize | Out-String | Write-Host
if ($env:GITHUB_STEP_SUMMARY) {
    "### hxcpp paradigms — native Windows x64" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    "| Model | DCE / gorilla | EXE bytes | Compile seconds CI |" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    "|---|---|---:|---:|" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    foreach ($x in $results) {
        "| $($x.variant) | $($x.mode) | $($x.executable_bytes) | $($x.compile_seconds) |" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    }
}
