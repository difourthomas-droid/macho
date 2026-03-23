# Fonction pour créer une chaîne multiligne Lua sécurisée comme dans Korium
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

$htmlContent = Get-Content -Path "menu_bnz.html" -Raw -Encoding UTF8

# Convertir le HTML en Data URI mais sans Base64 pour éviter l'erreur Lua <\239> ou d'autres erreurs d'encodage
$encodedHtml = [uri]::EscapeDataString($htmlContent)
$dataUri = "data:text/html;charset=utf-8," + $encodedHtml

$luaContent = Get-Content -Path "menu_bnz.lua" -Raw -Encoding UTF8

# Supprimer le BOM s'il est présent au début du fichier Lua original
if ($luaContent.Length -gt 0 -and $luaContent[0] -eq [char]0xFEFF) {
    $luaContent = $luaContent.Substring(1)
}

# Remplacer l'URL GitHub par notre Data URI
$searchPattern = 'local htmlPath = "https://difourthomas-droid.github.io/macho/windsurf-project-2/menu_bnz.html"'
$replaceString = "local htmlPath = " + (New-LuaLongString $dataUri)

$compiledLua = $luaContent.Replace($searchPattern, $replaceString)

# Sauvegarder strictement sans BOM en utilisant WriteAllBytes pour être 100% sûr
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$bytes = $utf8NoBom.GetBytes($compiledLua)
[System.IO.File]::WriteAllBytes("$PSScriptRoot\menu_bnz_compiled.lua", $bytes)

Write-Host "===============================================" -ForegroundColor Green
Write-Host "COMPILATION RÉUSSIE !" -ForegroundColor Green
Write-Host "Le fichier 'menu_bnz_compiled.lua' a été créé." -ForegroundColor Yellow
Write-Host "Le BOM UTF-8 a été retiré de force." -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Green
