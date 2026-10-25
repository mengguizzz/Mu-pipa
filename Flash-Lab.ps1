param(
    [string]$Image = ".\Mu-pipa.img",
    [string]$Slot = "",
    [switch]$NoReboot
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command fastboot -ErrorAction SilentlyContinue)) {
    throw "fastboot was not found in PATH"
}
if (-not (Test-Path -LiteralPath $Image)) {
    throw "UEFI image not found: $Image"
}

$product = (& fastboot getvar product 2>&1 | Out-String)
if ($product -notmatch "pipa") {
    throw "The connected fastboot device does not identify as Xiaomi Pad 6 (pipa).`n$product"
}

if (-not $Slot) {
    $slotText = (& fastboot getvar current-slot 2>&1 | Out-String)
    $match = [regex]::Match($slotText, "current-slot:\s*([ab])")
    if (-not $match.Success) {
        throw "Unable to determine the current A/B slot. Pass -Slot a or -Slot b."
    }
    $Slot = $match.Groups[1].Value
}

if ($Slot -notin @("a", "b")) {
    throw "Slot must be a or b"
}

$other = if ($Slot -eq "a") { "b" } else { "a" }

Write-Host "Mu-pipa USB lab flash plan"
Write-Host "  product: Xiaomi Pad 6 (pipa)"
Write-Host "  image:   $Image"
Write-Host "  target:  boot_$Slot"
Write-Host "  active:  $other -> $Slot"
Write-Host ""
Write-Host "The other Android boot slot is not modified. Keep a known-good boot.img backup."

$answer = Read-Host "Proceed? [y/N]"
if ($answer -notmatch "^[Yy]$") {
    exit 0
}

& fastboot flash "boot_$Slot" $Image
if ($LASTEXITCODE -ne 0) {
    throw "fastboot flash failed"
}

& fastboot set_active $other
& fastboot set_active $Slot

if (-not $NoReboot) {
    & fastboot reboot
}
