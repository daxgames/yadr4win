# PowerShell port of install_pacman.sh
# Lightweight translation intended to run under Windows PowerShell 5.1 and PowerShell 7+

# Ensure TLS 1.2 for GitHub downloads
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

Set-StrictMode -Version Latest

$Downloads = Join-Path $env:USERPROFILE 'Downloads'
if (-not (Test-Path $Downloads)) { New-Item -ItemType Directory -Path $Downloads | Out-Null }

# Determine architecture
$is32 = $false
if ($env:PROCESSOR_ARCHITECTURE -and $env:PROCESSOR_ARCHITECTURE -match '86') {
    # on Windows x86 vs x64 detection: treat x86 as 32-bit
    if ($env:PROCESSOR_ARCHITECTURE -eq 'x86') { $is32 = $true }
}
# Also support forced detection by OS bitness
if (-not $is32 -and -not [Environment]::Is64BitOperatingSystem) { $is32 = $true }

if ($is32) {
    $pacman = @(
        'pacman-6.0.0-4-i686.pkg.tar.zst',
        'pacman-mirrors-20210703-1-any.pkg.tar.zst',
        'msys2-keyring-1~20210213-2-any.pkg.tar.zst'
    )
    $zstd = 'zstd-1.5.0-1-i686.pkg.tar.xz'
    $zstd_win = 'https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win32.zip'
} else {
    $pacman = @(
        'pacman-6.0.1-18-x86_64.pkg.tar.zst',
        'pacman-mirrors-20220205-1-any.pkg.tar.zst',
        'msys2-keyring-1~20220623-1-any.pkg.tar.zst'
    )
    $zstd = 'zstd-1.5.2-1-x86_64.pkg.tar.xz'
    $zstd_win = 'https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win64.zip'
}

$bin_source = 'https://github.com/daxgames/pacman-for-git/raw/refs/heads/main'

function Download-File {
    param(
        [Parameter(Mandatory=$true)] [string]$Url,
        [Parameter(Mandatory=$true)] [string]$OutFile
    )
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($Url, $OutFile)
        return $true
    } catch {
        Write-Error "Failed to download $Url -> $OutFile : $_"
        return $false
    }
}

Write-Host '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
Write-Host 'Downloading pacman files...'
Write-Host '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'

foreach ($f in $pacman) {
    $url = "$bin_source/$f"
    $out = Join-Path $Downloads $f
    Write-Host "Downloading $url to $out"
    if (-not (Download-File -Url $url -OutFile $out)) { exit 1 }
}

Write-Host "`nDownloading zstd binaries...`n"
$zstdOut = Join-Path $Downloads $zstd
if (-not (Download-File -Url "$bin_source/$zstd" -OutFile $zstdOut)) { exit 1 }
$zstdZipOut = Join-Path $Downloads ([IO.Path]::GetFileName($zstd_win))
if (-not (Download-File -Url $zstd_win -OutFile $zstdZipOut)) { exit 1 }

# Extract zstd zip (Windows binary zip)
try {
    if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
        Expand-Archive -Path $zstdZipOut -DestinationPath $Downloads -Force
    } else {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zstdZipOut, $Downloads)
    }
} catch {
    Write-Warning "Could not expand ${zstdZipOut}: $_"
}

# Require tar.exe to extract pkg.tar archives
if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
    Write-Error 'tar.exe not found on PATH. This script relies on tar to extract package files. Aborting.'
    exit 1
}

Write-Host "`nExtracting zstd to /usr...`
"
# Note: extraction targets use MSYS-style root (/usr). If running on native Windows these paths likely do not exist.
try {
    & tar x --xz -vf $zstdOut usr
} catch {
    Write-Warning "Extraction of $zstdOut failed: $_"
}

foreach ($f in $pacman) {
    $in = Join-Path $Downloads $f
    Write-Host "Extracting $in to usr and etc..."
    try {
        & tar x --zstd -vf $in usr etc 2>$null
    } catch {
        Write-Warning "Failed to extract ${in}: $_"
    }
}

Write-Host "`nInitializing pacman...`n"
try {
    if (-not (Test-Path '/var/lib/pacman')) { New-Item -ItemType Directory -Force -Path '/var/lib/pacman' | Out-Null }
} catch {}

# Ensure gettext is available and symlinked if possible (best-effort)
try {
    $gettext = (Get-Command gettext -ErrorAction SilentlyContinue).Source
    if ($gettext) {
        # create symlink /usr/bin/gettext -> which gettext
        if (-not (Test-Path '/usr/bin')) { New-Item -ItemType Directory -Force -Path '/usr/bin' | Out-Null }
        try { New-Item -ItemType SymbolicLink -Path '/usr/bin/gettext' -Target $gettext -Force | Out-Null } catch { }
    }
} catch {}

# Initialize pacman keys (best-effort; requires pacman to be available in PATH)
if (Get-Command pacman-key -ErrorAction SilentlyContinue) {
    pacman-key --init
    pacman-key --populate msys2
    pacman -Syu --noconfirm
} else {
    Write-Warning 'pacman-key/pacman not found in PATH - skipping key init and system update'
}

Write-Host "`nGetting package versions for the installed Git release`n"
# Read installed package versions
# Allow override via variable or environment variable, otherwise probe common locations
$possible = @(
   (((get-command git).Path | split-path -parent | split-path -parent | split-path -parent) + "\etc\package-versions.txt"),
   (((get-command git).Path | split-path -parent | split-path -parent) + "\etc\package-versions.txt"),
   (((get-command git).Path | split-path -parent) + "\etc\package-versions.txt")
)

if ($env:PACKAGE_VERSIONS_PATH) { $possible = ,$env:PACKAGE_VERSIONS_PATH + $possible }
if ($null -ne $PackageVersionsPath -and $PackageVersionsPath -ne '') { $possible = ,$PackageVersionsPath + $possible }

$pkgVersionsPath = $possible | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $pkgVersionsPath) {
   Write-Error "Cannot find package-versions.txt. Searched: $($possible -join ', ')"
   exit 1
}
Write-Host "Using package-versions file: $pkgVersionsPath"

# Read package-versions.txt content
$pkgText = Get-Content $pkgVersionsPath -Raw
# find line like mingw-w64-*-git <version>
$match = Select-String -InputObject $pkgText -Pattern 'mingw-w64-[ix_0-9]+-git ' -AllMatches | Select-Object -First 1
if (-not $match) {
    Write-Error 'No mingw-w64-*-git entry found in package-versions.txt'
    exit 1
}
$t = $match.Matches[0].Value.Trim()

Write-Host "Getting commit ID that matches '$t' from $bin_source..."
# fetch version-tags.txt
$versionTags = $null
try {
    $wc = New-Object System.Net.WebClient
    $versionTags = $wc.DownloadString("$bin_source/version-tags.txt")
} catch {
    Write-Error "Failed to fetch version-tags.txt: $_"
    exit 1
}

# find a line containing $t
$lineMatch = ($versionTags -split "`n") | Where-Object { $_ -like "*${t}*" } | Select-Object -First 1
if (-not $lineMatch) {
    Write-Error 'ERROR: Commit ID not logged in github pacman-for-git.'
    exit 1
}

# last token is commit id
$commitId = ($lineMatch -split '\s+')[-1]
Write-Host "Using commit ID: $commitId"

# Determine sdk branch (32/64)
$b = 64
if ($t -match '-i686-') { $b = 32 }
$baseUrl = "https://github.com/git-for-windows/git-sdk-$b/raw/$commitId"

Write-Host "Downloading package database files from $baseUrl ..."

# For each package line in /etc/package-versions.txt: "pkg version"
$lines = Get-Content $pkgVersionsPath | Where-Object { $_ -match '\S' }
foreach ($ln in $lines) {
    $parts = $ln -split '\s+' | Where-Object { $_ -ne '' }
    if ($parts.Count -lt 2) { continue }
    $p = $parts[0]
    $v = $parts[1]
    $d = "/var/lib/pacman/local/$($p)-$($v)"
    try { New-Item -ItemType Directory -Force -Path $d | Out-Null } catch {}
    Write-Host "Preparing $d"
    foreach ($f in @('desc','files','mtree')) {
        $remote = "$baseUrl$d/$f"
        $out = "$d/$f"
        try {
            if (-not (Download-File -Url $remote -OutFile $out)) { Remove-Item -Force -Recurse $d -ErrorAction SilentlyContinue; Write-Warning "Missing $d"; break }
        } catch {}
    }
}

Write-Host "`nDone."
