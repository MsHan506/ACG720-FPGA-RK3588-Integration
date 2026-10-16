$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$bitstream = Join-Path $repo `
    'b_perception\camera\ov5640_ddr3_hdmi_full\impl\pnr\b_full_top.fs'
$expectedSize = 18973859
$expectedSha256 = `
    '46D673A364BD0A8DF0B9A1A1C7C8E040F19B74F90AC03507DED64F9A65B6B5BC'

if (-not (Test-Path -LiteralPath $bitstream)) {
    throw "Release bitstream is missing: $bitstream"
}

$item = Get-Item -LiteralPath $bitstream
if ($item.Length -ne $expectedSize) {
    throw "Unexpected bitstream size: $($item.Length), expected $expectedSize"
}

$actualSha256 = (Get-FileHash -LiteralPath $bitstream -Algorithm SHA256).Hash
if ($actualSha256 -ne $expectedSha256) {
    throw "Unexpected bitstream SHA-256: $actualSha256"
}

& (Join-Path $repo 'run_all_checks.ps1')
if ($LASTEXITCODE -ne 0) {
    throw 'Regression checks failed.'
}

Write-Output 'PASS release bitstream identity and all automated checks'
Write-Output "BITSTREAM $bitstream"
Write-Output "SIZE      $expectedSize"
Write-Output "SHA256    $expectedSha256"
