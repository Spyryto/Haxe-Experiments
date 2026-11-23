# Windows PE/link-map inspection; produces only observations, not false attribution of linked bytes.
$ErrorActionPreference = "Stop"
$destination = "dist/005-anatomy"
New-Item -ItemType Directory -Force $destination | Out-Null

function Read-PeSections([string]$file) {
    $data = [IO.File]::ReadAllBytes($file)
    if ($data.Length -lt 256 -or $data[0] -ne 77 -or $data[1] -ne 90) {
        throw "Not a PE/COFF executable: $file"
    }
    $pe = [BitConverter]::ToInt32($data, 60)
    if ($pe + 24 -ge $data.Length) { throw "Invalid PE offset: $file" }
    $count = [BitConverter]::ToUInt16($data, $pe + 6)
    $opt = [BitConverter]::ToUInt16($data, $pe + 20)
    $start = $pe + 24 + $opt
    $sections = @()
    for ($i = 0; $i -lt $count; $i++) {
        $off = $start + 40 * $i
        if ($off + 40 -gt $data.Length) { throw "Invalid section header: $file" }
        $name = [Text.Encoding]::ASCII.GetString($data, $off, 8).Trim([char]0)
        $sections += [ordered]@{
            name = $name
            virtual_bytes = [int64][BitConverter]::ToUInt32($data, $off + 8)
            file_raw_bytes = [int64][BitConverter]::ToUInt32($data, $off + 16)
        }
    }
    return $sections
}

function Find-Map([string]$mapName) {
    $found = @(
        Get-ChildItem -LiteralPath build -Recurse -File -Filter $mapName -ErrorAction SilentlyContinue
        Get-ChildItem -Path . -File -Filter $mapName
    ) | Sort-Object LastWriteTimeUtc -Descending
    if ($found.Count -eq 0) { throw "The linker did not produce $mapName (check HXCPP_MAP_FILE)" }
    return $found[0]
}

$cases = @(
    @{ name = "000-cli"; dir = "build/cli"; map = "scan-cli.map" },
    @{ name = "003-direct"; dir = "build/hxwidgets-direct"; map = "scan-direct.map" },
    @{ name = "002-haxeui"; dir = "build/haxeui-wxwidgets"; map = "scan-haxeui.map" }
)
$results = @()
foreach ($item in $cases) {
    $name = $item.name
    $exe = Get-ChildItem -Path $item.dir -Recurse -File -Filter Main.exe | Select-Object -First 1
    if ($null -eq $exe) { throw "Missing EXE $name" }

    $sections = @(Read-PeSections $exe.FullName)
    # OrderedDictionary key/value pairs are not regular PowerShell properties.
    $sectionBytes = [int64]0
    foreach ($section in $sections) { $sectionBytes += [int64]$section["file_raw_bytes"] }
    $map = Find-Map $item.map
    Copy-Item -LiteralPath $map.FullName -Destination "$destination/$name.map"
    $mapLines = [IO.File]::ReadAllLines($map.FullName)
    # We can count public symbols, but cannot infer exact contribution bytes
    # from their count or from raw .obj/.lib sizes.
    $inPublics = $false
    $inStatic = $false
    $publicSymbols = 0
    $staticSymbols = 0
    $originCount = @{}
    foreach ($line in $mapLines) {
        if ($line -match 'Publics by Value') { $inPublics = $true; $inStatic = $false; continue }
        if ($line -match 'Static symbols') { $inPublics = $false; $inStatic = $true; continue }
        if (-not ($inPublics -or $inStatic)) { continue }
        # MSVC can include "f i" flags before the final Lib:Object token.
        $columns = $line.Trim() -split '\s+'
        if ($columns.Count -ge 4 -and
            $columns[0] -match '^[0-9A-Fa-f]{4}:[0-9A-Fa-f]{8}$' -and
            $columns[2] -match '^[0-9A-Fa-f]{16}$') {
            if ($inPublics) { $publicSymbols++ } else { $staticSymbols++ }
            $source = $columns[-1]
            if ($originCount.ContainsKey($source)) { $originCount[$source]++ }
            else { $originCount[$source] = 1 }
        }
    }
    $topOrigins = @(
        $originCount.GetEnumerator() |
            Sort-Object Value -Descending |
            Select-Object -First 25 |
            ForEach-Object { [ordered]@{ object = $_.Key; map_symbols = $_.Value } }
    )

    $dump = & dumpbin.exe /headers $exe.FullName | Out-String
    if ($LASTEXITCODE -ne 0) { throw "dumpbin headers failed for $name" }
    Set-Content -Path "$destination/$name.headers.txt" -Value $dump
    $deps = & dumpbin.exe /dependents $exe.FullName | Out-String
    if ($LASTEXITCODE -ne 0) { throw "dumpbin dependents failed for $name" }
    Set-Content -Path "$destination/$name.dependencies.txt" -Value $deps

    $obj = @(Get-ChildItem -Path $item.dir -Recurse -Filter '*.obj' -File -ErrorAction SilentlyContinue)
    $objBytes = ($obj | Measure-Object -Property Length -Sum).Sum
    $topObjects = @(
        $obj | Sort-Object Length -Descending | Select-Object -First 20 |
        ForEach-Object { [ordered]@{
            path = $_.FullName.Substring((Get-Location).Path.Length + 1)
            prelink_bytes = [int64]$_.Length
        } }
    )
    $results += [ordered]@{
        name = $name
        executable_bytes = [int64]$exe.Length
        pe_file_section_raw_sum_bytes = [int64]$sectionBytes
        pe_sections = $sections
        map_file_bytes = [int64]$map.Length
        map_public_symbols_count = $publicSymbols
        map_static_symbols_count = $staticSymbols
        map_all_symbol_origins_count = $originCount.Count
        map_top_symbol_origins_by_count = $topOrigins
        prelink_object_files_count = $obj.Count
        prelink_object_file_bytes_sum = [int64]$objBytes
        prelink_largest_objects = $topObjects
    }
}

$wxLibs = @(Get-ChildItem -LiteralPath "$env:WXWIN/lib/vc_x64_lib" -Filter "*.lib" -File)
$inputs = [ordered]@{
    disclaimer = "Static library sizes are INPUT sizes, NOT linked byte contributions. Counts of map symbols do not measure size. PE raw sections are actual EXE byte sizes."
    wxwidgets_static_library_count = $wxLibs.Count
    wxwidgets_static_input_bytes = [int64](($wxLibs | Measure-Object -Property Length -Sum).Sum)
    top_wxwidgets_libraries = @(
        $wxLibs | Sort-Object Length -Descending | Select-Object -First 20 |
        ForEach-Object { [ordered]@{ library = $_.Name; prelink_bytes = [int64]$_.Length } }
    )
    executables = $results
}
$inputs | ConvertTo-Json -Depth 12 | Set-Content "$destination/measurements.json"
foreach ($r in $results) {
    Write-Host "$($r.name): EXE $($r.executable_bytes) bytes, PE sections $($r.pe_file_section_raw_sum_bytes) bytes; MAP $($r.map_public_symbols_count) public + $($r.map_static_symbols_count) static symbols, $($r.map_all_symbol_origins_count) origins"
    $r.pe_sections | Format-Table -AutoSize | Out-String | Write-Host
}
if ($env:GITHUB_STEP_SUMMARY) {
    "### PE sections and linker maps (Windows x64, identical tools)" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    "| Binary | EXE bytes | Section raw bytes | MAP public + static | MAP origins |" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    "|---|---:|---:|---:|---:|" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    foreach ($r in $results) {
        "| $($r.name) | $($r.executable_bytes) | $($r.pe_file_section_raw_sum_bytes) | $($r.map_public_symbols_count + $r.map_static_symbols_count) | $($r.map_all_symbol_origins_count) |" | Out-File $env:GITHUB_STEP_SUMMARY -Append
    }
    "Full per-section data and linker maps in artifact. Object/library sizes **before linking are not sizes included in the EXE**." | Out-File $env:GITHUB_STEP_SUMMARY -Append
}
