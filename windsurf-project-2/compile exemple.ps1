param(
    [string]$Type = "all",
    [switch]$RemoveCommentsOnly
)

$ErrorActionPreference = "Stop"

$baseDir = $PSScriptRoot
$srcDir = Join-Path $baseDir "src"

if ($RemoveCommentsOnly) {
    Write-Host "[INFO] Removing comments from src directory..."
    $luaFiles = Get-ChildItem -Path $srcDir -Filter "*.lua" -Recurse
    $pattern = '(--\[(=*)\[[\s\S]*?\]\2\]|--.*)|("[^"\\]*(?:\\.[^"\\]*)*"|''[^''\\]*(?:\\.[^''\\]*)*''|\[(=*)\[[\s\S]*?\]\4\])'
    
    foreach ($file in $luaFiles) {
        $content = Get-Content $file.FullName -Raw
        $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, '$3')
        $content = $content -replace '(?m)^\s*$', ''
        Set-Content -Path $file.FullName -Value $content
        Write-Host "Processed: $($file.Name)"
    }
    Write-Host "[INFO] Comments removed from all files in src."
    exit
}

Write-Host "[INFO] Starting compilation..."
$distDir = Join-Path $baseDir "dist"
if (!(Test-Path -Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir | Out-Null
}

Write-Host "[INFO] Building loader.lua..."
$loaderOut = Join-Path $distDir "loader.lua"
$loaderTemp = Join-Path $baseDir "loader_temp.lua"
if (Test-Path $loaderOut) { Remove-Item $loaderOut }
if (Test-Path $loaderTemp) { Remove-Item $loaderTemp }

$debugPath = Join-Path $srcDir "bootstrap\debug.lua"
if (Test-Path $debugPath) {
    Get-Content $debugPath -Raw | Add-Content $loaderTemp
    Add-Content $loaderTemp "`n"
}

# Crypto
$cryptoPath = Join-Path $srcDir "bootstrap\crypto.lua"
if (Test-Path $cryptoPath) {
    Get-Content $cryptoPath -Raw | Add-Content $loaderTemp
    Add-Content $loaderTemp "`n"
}

# Protection modules
$protectionDir = Join-Path $srcDir "bootstrap\Protection"
$protectionFiles = @("logging.lua", "auth.lua")
foreach ($pf in $protectionFiles) {
    $pfPath = Join-Path $protectionDir $pf
    if (Test-Path $pfPath) {
        Get-Content $pfPath -Raw | Add-Content $loaderTemp
        Add-Content $loaderTemp "`n"
    }
}

# Server Names (extract from index.lua for whitelist check in loader)
$serverIndexForLoader = Join-Path $srcDir "server_config\index.lua"
if (Test-Path $serverIndexForLoader) {
    $indexRaw = Get-Content $serverIndexForLoader -Raw
    $nameMatches = [regex]::Matches($indexRaw, '\[\d+\]\s*=\s*"([^"]+)"')
    $nameEntries = @()
    foreach ($m in $nameMatches) {
        $escaped = $m.Groups[1].Value -replace '\\', '\\\\' -replace '"', '\"'
        $nameEntries += "`"$escaped`""
    }
    if ($nameEntries.Count -gt 0) {
        $namesLua = "_G.KORIUM_SERVER_NAMES = {" + ($nameEntries -join ",") + "}`n"
        Add-Content $loaderTemp $namesLua
    }
}

# Loader Logic
$loaderSrcPath = Join-Path $srcDir "bootstrap\loader.lua"
if (Test-Path $loaderSrcPath) {
    Get-Content $loaderSrcPath -Raw | Add-Content $loaderTemp
    Add-Content $loaderTemp "`n"
} else {
    Write-Error "[ERROR] loader.lua not found in $srcDir"
    exit 1
}

$loaderContent = Get-Content $loaderTemp -Raw
$pattern = '(--\[(=*)\[[\s\S]*?\]\2\]|--.*)|("[^"\\]*(?:\\.[^"\\]*)*"|''[^''\\]*(?:\\.[^''\\]*)*''|\[(=*)\[[\s\S]*?\]\4\])'
$loaderContent = [System.Text.RegularExpressions.Regex]::Replace($loaderContent, $pattern, '$3')
$loaderContent = $loaderContent -replace '(?m)^\s*$', ''

Set-Content -Path $loaderOut -Value $loaderContent
Remove-Item $loaderTemp

function New-LuaLongString {
    param(
        [string]$Value
    )

    if ($null -eq $Value) {
        $Value = ""
    }

    $eq = 0
    while ($Value -match ("\]" + ("=" * $eq) + "\]")) {
        $eq = $eq + 1
    }

    $open = "[" + ("=" * $eq) + "["
    $close = "]" + ("=" * $eq) + "]"
    return $open + $Value + $close
}

function Build-Payload {
    param (
        [string]$OutputPath,
        [bool]$Minify,
        [string]$BuildType
    )
    
    $tempFile = Join-Path $baseDir "payload_temp.lua"
    if (Test-Path $tempFile) { Remove-Item $tempFile }
    
    $clientDir = Join-Path $srcDir "client"

    if ($BuildType -eq "dev") {
        Add-Content $tempFile "_G.KORIUM_BUILD = 'dev'`n"
        Add-Content $tempFile "_G.KORIUM_SILENT = false`n"
        Add-Content $tempFile "if type(_G.__KORIUM_ENABLE_THREAD_DEBUG) == 'function' then _G.__KORIUM_ENABLE_THREAD_DEBUG() end`n"
    } else {
        Add-Content $tempFile "_G.KORIUM_BUILD = 'user'`n"
        Add-Content $tempFile "_G.KORIUM_SILENT = true`n"
        Add-Content $tempFile "_G._realprint = print`n"
        Add-Content $tempFile "print = function(...) end`n"
    }
    Add-Content $tempFile "`n"
    
    # Config
    $configPath = Join-Path $clientDir "Config\menu.lua"
    if (Test-Path $configPath) {
        Add-Content $tempFile "local MenuConfig = (function()`n"
        Get-Content $configPath -Raw | Add-Content $tempFile
        Add-Content $tempFile "`nend)()`n"
    }

    $serverConfigDir = Join-Path $srcDir "server_config"
    $serverIndexPath = Join-Path $serverConfigDir "index.lua"
    $serverProfilesDir = Join-Path $serverConfigDir "profiles"
    if (Test-Path $serverIndexPath) {
        Add-Content $tempFile "_G.KoriumEmbeddedFiles = _G.KoriumEmbeddedFiles or {}`n"
        $indexContent = Get-Content $serverIndexPath -Raw
        Add-Content $tempFile ("_G.KoriumEmbeddedFiles['config/index.lua'] = " + (New-LuaLongString $indexContent) + "`n")

        if (Test-Path $serverProfilesDir) {
            $profileFiles = Get-ChildItem -Path $serverProfilesDir -Filter "*.lua" | Sort-Object Name
            foreach ($pf in $profileFiles) {
                $relPath = "config/profiles/" + $pf.Name
                $pfContent = Get-Content $pf.FullName -Raw
                Add-Content $tempFile ("_G.KoriumEmbeddedFiles['" + $relPath + "'] = " + (New-LuaLongString $pfContent) + "`n")
            }
        }

        Add-Content $tempFile "`n"
    }

    # Nui
    $nuiDir = Join-Path $clientDir "Nui"
    $nuiFilesOrdered = @(
        (Join-Path $nuiDir "Core\init.lua"),
        (Join-Path $nuiDir "Ui\icons.lua"),
        (Join-Path $nuiDir "Ui\builders.lua"),
        (Join-Path $nuiDir "Core\core.lua"),
        (Join-Path $nuiDir "Components\loading.lua"),
        (Join-Path $nuiDir "Ui\selector.lua"),
        (Join-Path $nuiDir "Components\notifications.lua"),
        (Join-Path $nuiDir "Components\prompt.lua"),
        (Join-Path $nuiDir "Components\keyprompt.lua"),
        (Join-Path $nuiDir "Components\branding.lua"),
        (Join-Path $nuiDir "Ui\colorpicker.lua"),
        (Join-Path $nuiDir "Ui\design.lua")
    )
    foreach ($p in $nuiFilesOrdered) {
        if (Test-Path $p) {
            Add-Content $tempFile "do`n"
            Get-Content $p -Raw | Add-Content $tempFile
            Add-Content $tempFile "`nend`n"
        }
    }

    # Helper
    $helperDir = Join-Path $clientDir "Helper"
    if (Test-Path $helperDir) {
        $helperFiles = Get-ChildItem -Path $helperDir -Filter "*.lua"
        foreach ($file in $helperFiles) {
            Add-Content $tempFile "do`n"
            Get-Content $file.FullName -Raw | Add-Content $tempFile
            Add-Content $tempFile "`nend`n"
        }
    }

    $entryPath = Join-Path $clientDir "entry.lua"
    $configDir = Join-Path $clientDir "Config"

    $clientFiles = Get-ChildItem -Path $clientDir -Filter "*.lua" -Recurse | Where-Object {
        $_.FullName -ne $entryPath -and
        $_.FullName -notlike "$nuiDir*" -and
        $_.FullName -notlike "$helperDir*" -and
        $_.FullName -notlike "$configDir*"
    }
    foreach ($file in $clientFiles) {
        Add-Content $tempFile "do`n"
        Get-Content $file.FullName -Raw | Add-Content $tempFile
        Add-Content $tempFile "`nend`n"
    }

    if (Test-Path $entryPath) {
        Get-Content $entryPath -Raw | Add-Content $tempFile
        Add-Content $tempFile "`n"
    }

    $content = Get-Content -Path $tempFile -Raw
    if ($Minify) {
        $pattern = '(--\[(=*)\[[\s\S]*?\]\2\]|--.*)|("[^"\\]*(?:\\.[^"\\]*)*"|''[^''\\]*(?:\\.[^''\\]*)*''|\[(=*)\[[\s\S]*?\]\4\])'
        $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, '$3')
        $content = $content -replace '(?m)^\s*$', ''
    }
    
    Set-Content -Path $OutputPath -Value $content
    Remove-Item $tempFile
}

if ($Type -eq "all" -or $Type -eq "user") {
    Write-Host "[INFO] Building client.lua (User)..."
    Build-Payload -OutputPath (Join-Path $distDir "client.lua") -Minify $true -BuildType "user"
}

if ($Type -eq "all" -or $Type -eq "dev") {
    Write-Host "[INFO] Building client_dev.lua (Dev)..."
    Build-Payload -OutputPath (Join-Path $distDir "client_dev.lua") -Minify $true -BuildType "dev"
}

Write-Host "[INFO] Removing dist/config directory (embedded profiles)..."
$configDistDir = Join-Path $distDir "config"
if (Test-Path $configDistDir) { Remove-Item $configDistDir -Recurse -Force }

Write-Host "[INFO] Compilation complete!"

Write-Host "[INFO] Zipping final Lua files..."
$filesToZip = @()

$potentialFiles = @(
    "loader.lua",
    "client.lua",
    "client_dev.lua",
    "fxmanifest.lua"
)

foreach ($file in $potentialFiles) {
    $fullPath = Join-Path $distDir $file
    if (Test-Path $fullPath) {
        $filesToZip += $fullPath
    }
}

$zipPath = Join-Path $distDir "output.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

if ($filesToZip.Count -gt 0) {
    Compress-Archive -Path $filesToZip -DestinationPath $zipPath -Force
    Write-Host "[INFO] Files zipped to $zipPath"
} else {
    Write-Warning "[WARN] No files to zip!"
}
