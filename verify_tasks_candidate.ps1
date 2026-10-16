$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$bitstream = Join-Path $repo `
    'b_perception\camera\ov5640_ddr3_hdmi_full\impl\pnr\b_full_tasks_candidate.fs'
$expectedSize = 18757811
$expectedSha256 = `
    '8F58619148BB1A7C74A18C595C7FDD9B8B7135F4007413E3906FD24FF667E8A3'

if (-not (Test-Path -LiteralPath $bitstream)) {
    throw "Candidate bitstream is missing: $bitstream"
}
$item = Get-Item -LiteralPath $bitstream
if ($item.Length -ne $expectedSize) {
    throw "Unexpected candidate size: $($item.Length), expected $expectedSize"
}
$actualSha256 = (Get-FileHash -LiteralPath $bitstream -Algorithm SHA256).Hash
if ($actualSha256 -ne $expectedSha256) {
    throw "Unexpected candidate SHA-256: $actualSha256"
}

& (Join-Path $repo 'run_all_checks.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Regression checks failed.' }

Write-Output 'PASS candidate identity and all automated checks'
Write-Output "BITSTREAM $bitstream"
Write-Output "SIZE      $expectedSize"
Write-Output "SHA256    $expectedSha256"
