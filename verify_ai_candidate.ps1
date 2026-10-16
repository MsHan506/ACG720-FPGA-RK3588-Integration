$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$bitstream = Join-Path $repo 'b_perception\camera\ov5640_ddr3_hdmi_full\impl\pnr\b_full_ai_tasks_candidate.fs'
$model = Join-Path $repo 'edge_ai\models\object_detection_yolox_2022nov.onnx'
$expectedBitstreamSize = 18902163
$expectedBitstreamHash = '04BA67871E49EC704E5B9424C45FDF19CA31DA64062406722654CE06D6A6FC2A'
$expectedModelSize = 35858002
$expectedModelHash = 'C5C2D13E59AE883E6AF3B45DAEA64AF4833A4951C92D116EC270D9DDBE998063'

foreach ($item in @(
    @($bitstream, $expectedBitstreamSize, $expectedBitstreamHash),
    @($model, $expectedModelSize, $expectedModelHash))) {
    if (-not (Test-Path -LiteralPath $item[0])) { throw "Missing: $($item[0])" }
    if ((Get-Item -LiteralPath $item[0]).Length -ne $item[1]) {
        throw "Unexpected size: $($item[0])"
    }
    if ((Get-FileHash -LiteralPath $item[0] -Algorithm SHA256).Hash -ne $item[2]) {
        throw "Unexpected SHA-256: $($item[0])"
    }
}

& (Join-Path $repo 'run_all_checks.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Regression checks failed.' }

Push-Location $repo
try {
    python -c "import numpy as np; from edge_ai.detector import YoloXDetector; d=YoloXDetector(r'$model'); d.detect(np.zeros((480,640,3),np.uint8)); print('PASS YOLOX model load and inference')"
    if ($LASTEXITCODE -ne 0) { throw 'YOLOX inference smoke test failed.' }
} finally { Pop-Location }

Write-Output 'PASS AI candidate identity, FPGA/Python regressions, and model inference'
Write-Output "BITSTREAM $bitstream"
Write-Output "BITSTREAM_SHA256 $expectedBitstreamHash"
Write-Output "MODEL $model"
Write-Output "MODEL_SHA256 $expectedModelHash"
