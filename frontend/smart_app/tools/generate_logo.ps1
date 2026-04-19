# Smart App Logo Generator
# Creates:
#   app_icon.png            - 1024x1024, rounded gradient bg + white bolt (for iOS/store)
#   app_icon_foreground.png - 1024x1024, transparent bg + larger white bolt (Android adaptive)

Add-Type -AssemblyName System.Drawing

function Build-BoltPath {
    param([float]$Cx, [float]$Cy, [float]$Scale)

    # Lightning bolt in normalized units (approx 200 wide x 400 tall, centered on origin)
    # Classic asymmetric bolt: top-right to bottom-left zigzag
    $pts = @(
        @( 40, -200),   # top-right
        @(-60, -200),   # top-left
        @(-100,  10),   # left notch
        @(-20,   10),   # left inner
        @(-60,  200),   # bottom point
        @( 80,  -30),   # right inner
        @(  0,  -30)    # right notch
    )

    $points = @()
    foreach ($p in $pts) {
        $x = $Cx + ($p[0] * $Scale)
        $y = $Cy + ($p[1] * $Scale)
        $points += New-Object System.Drawing.PointF $x, $y
    }

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon($points)
    return $path
}

function New-SmartAppIcon {
    param(
        [int]$Size = 1024,
        [string]$OutPath,
        [bool]$WithBackground = $true
    )

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    if ($WithBackground) {
        $radius = $Size * 0.22
        $rect = New-Object System.Drawing.RectangleF 0, 0, $Size, $Size
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $radius * 2
        $path.AddArc(0, 0, $d, $d, 180, 90)
        $path.AddArc(($Size - $d), 0, $d, $d, 270, 90)
        $path.AddArc(($Size - $d), ($Size - $d), $d, $d, 0, 90)
        $path.AddArc(0, ($Size - $d), $d, $d, 90, 90)
        $path.CloseFigure()

        $c1 = [System.Drawing.Color]::FromArgb(255, 108, 99, 255)   # #6C63FF
        $c2 = [System.Drawing.Color]::FromArgb(255, 0, 191, 255)    # #00BFFF
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, $c1, $c2, 45.0
        $g.FillPath($brush, $path)
        $brush.Dispose()
        $path.Dispose()
    }

    # Bolt scale — larger when no background (foreground adaptive icon safe zone ~66%)
    $cx = $Size / 2
    $cy = $Size / 2
    $scale = if ($WithBackground) { $Size / 650.0 } else { $Size / 500.0 }

    # Drop shadow (offset bolt)
    $shadowOffset = $Size * 0.01
    $shadowPath = Build-BoltPath -Cx ($cx + $shadowOffset) -Cy ($cy + $shadowOffset) -Scale $scale
    $shadowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(60, 0, 0, 0))
    $g.FillPath($shadowBrush, $shadowPath)
    $shadowBrush.Dispose()
    $shadowPath.Dispose()

    # White bolt
    $boltPath = Build-BoltPath -Cx $cx -Cy $cy -Scale $scale
    $whiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $g.FillPath($whiteBrush, $boltPath)
    $whiteBrush.Dispose()
    $boltPath.Dispose()

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()

    Write-Host "Saved: $OutPath"
}

$outDir = Join-Path $PSScriptRoot "..\assets\logo"
$outDir = [System.IO.Path]::GetFullPath($outDir)
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

New-SmartAppIcon -Size 1024 -OutPath (Join-Path $outDir "app_icon.png") -WithBackground $true
New-SmartAppIcon -Size 1024 -OutPath (Join-Path $outDir "app_icon_foreground.png") -WithBackground $false

Write-Host ""
Write-Host "Logo generation complete."
