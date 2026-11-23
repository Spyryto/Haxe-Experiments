$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force dist/paradigms | Out-Null
$styles = @('inheritance','composition','fp')
$iterations = 3000000
$repetitions = 7
$results = @()
$expected = $null

foreach ($style in $styles) {
  $dir = "build/paradigms/$style"
  $exe = Get-ChildItem $dir -Recurse -Filter 'Main.exe' -File | Select-Object -First 1
  if (!$exe) { throw "Missing exe: $style" }
  $target = "dist/paradigms/$style.exe"
  Copy-Item -LiteralPath $exe.FullName -Destination $target
  $hash = $null
  $times = @()
  for ($i = 0; $i -lt $repetitions; $i++) {
    $output = & $target $iterations
    if ($LASTEXITCODE -ne 0) { throw "Program failed: $style" }
    $map = @{}
    foreach ($line in $output) {
      if ($line -match '^([^=]+)=(.+)$') { $map[$matches[1]] = $matches[2] }
    }
    if (!$map.ContainsKey('checksum') -or !$map.ContainsKey('runtime_ms')) { throw "Incomplete output from $style : $output" }
    if ($null -eq $hash) { $hash = $map['checksum'] }
    if ($hash -ne $map['checksum']) { throw "Inconsistent checksum on repeated $style runs" }
    $times += [double]::Parse($map['runtime_ms'], [Globalization.CultureInfo]::InvariantCulture)
  }
  if ($null -eq $expected) { $expected = $hash }
  if ($hash -ne $expected) { throw "MISMATCH: $style checksum $hash != $expected" }
  $sorted = @($times | Sort-Object)
  $bytes = [int64](Get-Item $target).Length
  $obj = @(Get-ChildItem $dir -Recurse -Filter '*.obj' -File)
  $objBytes = [int64](($obj | Measure-Object Length -Sum).Sum)
  $headers = & dumpbin.exe /headers $target | Out-String
  $deps = & dumpbin.exe /dependents $target | Out-String
  if ($LASTEXITCODE -ne 0) { throw "dumpbin failed: $style" }
  Set-Content -Path "dist/paradigms/$style.headers.txt" -Value $headers
  Set-Content -Path "dist/paradigms/$style.dependencies.txt" -Value $deps
  $result = [ordered]@{
    style = $style
    executable_bytes = $bytes
    object_files_total_bytes = $objBytes
    object_file_count = $obj.Count
    checksum = $hash
    iterations = $iterations
    runs_ms = $times
    median_ms = $sorted[3]
  }
  $results += $result
}
$all = [ordered]@{ platform="windows-x64"; repetitions=$repetitions; results=$results }
$all | ConvertTo-Json -Depth 7 | Set-Content dist/paradigms/measurements.json
$lines = @("### OOP / FP native comparison", "| Style | EXE bytes | Median ms | .obj bytes |", "|---|---:|---:|---:|")
foreach ($r in $results) {
  $lines += "| $($r.style) | $($r.executable_bytes) | $($r.median_ms) | $($r.object_files_total_bytes) |"
}
$lines += "Checksums identical: $expected"
$lines | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Append -Encoding utf8
Write-Host ($all | ConvertTo-Json -Depth 7)
