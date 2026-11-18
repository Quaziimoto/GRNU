# rutils dev environment for PowerShell.
# Usage (from anywhere):   . .\rutils\env\activate.ps1
# Leave it with:           deactivate-rutils
# Only affects the current terminal session.

$script:RutilsRoot = Split-Path -Parent $PSScriptRoot
$script:RutilsBin  = Join-Path $RutilsRoot "target\debug"

# Build so the binaries are up to date
Write-Host "rutils: building..." -ForegroundColor DarkGray
cargo build --quiet --manifest-path (Join-Path $RutilsRoot "Cargo.toml")
if ($LASTEXITCODE -ne 0) {
    Write-Host "rutils: build failed, environment not activated" -ForegroundColor Red
    return
}

# Save state so deactivate can restore it
if (-not $env:RUTILS_ACTIVE) {
    $script:RutilsOldPath = $env:PATH
    $script:RutilsOldPrompt = $function:prompt
}
$env:RUTILS_ACTIVE = "1"

# Put the freshly built binaries first on PATH (rls, rpwd, rcd.exe ...)
$env:PATH = "$RutilsBin;$script:RutilsOldPath"

# rcd prints the target dir; this wrapper actually moves the shell there
function global:rcd {
    $target = & (Join-Path $script:RutilsBin "rcd.exe") @args
    if ($LASTEXITCODE -eq 0) {
        $env:OLDPWD = $PWD.Path
        Set-Location $target
    }
}

# Rebuild without leaving the environment
function global:rebuild-rutils {
    cargo build --quiet --manifest-path (Join-Path $script:RutilsRoot "Cargo.toml")
}

function global:prompt {
    "(rutils) " + (& $script:RutilsOldPrompt)
}

function global:deactivate-rutils {
    $env:PATH = $script:RutilsOldPath
    $function:global:prompt = $script:RutilsOldPrompt
    Remove-Item Env:RUTILS_ACTIVE -ErrorAction SilentlyContinue
    Remove-Item Function:\rcd, Function:\rebuild-rutils, Function:\deactivate-rutils -ErrorAction SilentlyContinue
}

Write-Host "rutils: active. Commands from $RutilsBin. Run 'deactivate-rutils' to leave." -ForegroundColor Green
