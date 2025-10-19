Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Build-Playlists.ps1  (run from project root containing index.html)
$ErrorActionPreference = "Stop"

# Root where index.html points via: <base href="./resources/">
$resourcesRoot = (Resolve-Path ".\resources").Path

function Get-RelPaths {
  param(
    [Parameter(Mandatory = $true)][string]$Folder,
    [string[]]$Filters = @("*.mp3","*.m4a","*.wav","*.ogg")
  )

  if (-not (Test-Path $Folder)) {
    return @()  # Always return an array
  }

  $files = foreach ($f in $Filters) { Get-ChildItem $Folder -File -Recurse -Filter $f }
  $files = $files | Sort-Object Name

  $out = New-Object System.Collections.Generic.List[string]
  foreach ($file in $files) {
    $full = $file.FullName

    # Compute path relative to resourcesRoot without GetRelativePath (works on PS 5.1)
    if ($full.StartsWith($resourcesRoot, $true, [Globalization.CultureInfo]::InvariantCulture)) {
      $rel = $full.Substring($resourcesRoot.Length).TrimStart('\','/')
    } else {
      $baseUri = [Uri](($resourcesRoot.TrimEnd('\','/')) + [IO.Path]::DirectorySeparatorChar)
      $relUri  = $baseUri.MakeRelativeUri([Uri]$full)
      $rel = [Uri]::UnescapeDataString($relUri.ToString())
    }

    $rel = $rel -replace '\\','/'
    $out.Add("./$rel")  # correct for <base href="./resources/">
  }
  return ,$out.ToArray()  # Force array semantics even if 0 or 1 item
}

# Folders under resources\Music
$musicRoot      = Join-Path $resourcesRoot "Music"
$normalFolder   = Join-Path $musicRoot "Normal"
$halloweenDir   = Join-Path $musicRoot "Halloween"
$xmasDir        = Join-Path $musicRoot "Xmas"
$aprilFoolsDir  = Join-Path $musicRoot "AprilFools"

$loop        = Get-RelPaths -Folder $normalFolder
$halloween   = Get-RelPaths -Folder $halloweenDir
$xmas        = Get-RelPaths -Folder $xmasDir
$aprilfools  = Get-RelPaths -Folder $aprilFoolsDir

# Build JS (window.PLAYLISTS = { ... };)
$data = @{
  loop        = $loop
  halloween   = $halloween
  xmas        = $xmas
  aprilfools  = $aprilfools
} | ConvertTo-Json -Depth 5

$js = "window.PLAYLISTS = $data;`n"

# Ensure resources exists and write file
New-Item -Type Directory -Force ".\resources" | Out-Null
$dest = ".\resources\playlists.generated.js"
$js | Set-Content -Path $dest -Encoding UTF8

Write-Host ("Wrote {0}" -f $dest)
Write-Host ("Counts - loop:{0} halloween:{1} xmas:{2} aprilfools:{3}" -f $loop.Count, $halloween.Count, $xmas.Count, $aprilfools.Count)
