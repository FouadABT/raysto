# Rebuild original Raysto icon geometry using Windows .NET drawing primitives.
# No source photographs or third-party icon artwork are used by this script.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$raystoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))

function Write-RaystoIcon([int]$pixels, [string]$destination, [bool]$rounded, [bool]$transparent) {
    $bitmapFormat = if ($transparent) { [Drawing.Imaging.PixelFormat]::Format32bppArgb } else { [Drawing.Imaging.PixelFormat]::Format24bppRgb }
    $bitmap = [Drawing.Bitmap]::new($pixels, $pixels, $bitmapFormat)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $forest = [Drawing.Color]::FromArgb(23, 63, 53)
    $paper = [Drawing.Color]::FromArgb(246, 247, 242)
    $lime = [Drawing.Color]::FromArgb(215, 249, 120)
    $graphics.Clear($(if ($transparent) { [Drawing.Color]::Transparent } elseif ($rounded) { $paper } else { $forest }))
    $graphics.ScaleTransform($pixels / 108.0, $pixels / 108.0)

    if ($rounded) {
        $tile = [Drawing.Drawing2D.GraphicsPath]::new()
        $tile.AddArc(0, 0, 48, 48, 180, 90)
        $tile.AddArc(60, 0, 48, 48, 270, 90)
        $tile.AddArc(60, 60, 48, 48, 0, 90)
        $tile.AddArc(0, 60, 48, 48, 90, 90)
        $tile.CloseFigure()
        $brush = [Drawing.SolidBrush]::new($forest)
        $graphics.FillPath($brush, $tile)
        $brush.Dispose()
        $tile.Dispose()
    }

    $mark = [Drawing.Drawing2D.GraphicsPath]::new()
    $mark.StartFigure()
    $mark.AddLine(31, 29, 31, 43)
    $mark.AddBezier(31, 43, 31, 49.6667, 34.3333, 53, 41, 53)
    $mark.AddBezier(41, 53, 47.6667, 53, 51, 49.6667, 51, 43)
    $mark.AddLine(51, 43, 51, 29)
    $mark.StartFigure()
    $mark.AddLine(41, 29, 41, 79)
    $mark.StartFigure()
    $mark.AddBezier(76, 29, 68, 35, 64, 44, 64, 56)
    $mark.AddLine(64, 56, 76, 56)
    $mark.AddLine(76, 56, 76, 79)
    $mark.StartFigure()
    $mark.AddLine(76, 29, 76, 56)
    $pen = [Drawing.Pen]::new($lime, 5.5)
    $pen.StartCap = [Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [Drawing.Drawing2D.LineJoin]::Round
    $graphics.DrawPath($pen, $mark)
    $bitmap.Save($destination, [Drawing.Imaging.ImageFormat]::Png)
    $pen.Dispose()
    $mark.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

$iconFolder = Join-Path $raystoRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$iconManifest = Get-Content (Join-Path $iconFolder 'Contents.json') -Raw | ConvertFrom-Json
$written = @{}
foreach ($entry in $iconManifest.images) {
    if ($written.ContainsKey($entry.filename)) { continue }
    $points = [double]::Parse(($entry.size -split 'x')[0], [Globalization.CultureInfo]::InvariantCulture)
    $scale = [int](($entry.scale -split 'x')[0])
    Write-RaystoIcon ([int]($points * $scale)) (Join-Path $iconFolder $entry.filename) $false $false
    $written[$entry.filename] = $true
}

$launchFolder = Join-Path $raystoRoot 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
Write-RaystoIcon 108 (Join-Path $launchFolder 'LaunchImage.png') $true $false
Write-RaystoIcon 216 (Join-Path $launchFolder 'LaunchImage@2x.png') $true $false
Write-RaystoIcon 324 (Join-Path $launchFolder 'LaunchImage@3x.png') $true $false

$densities = @{ 'mdpi' = 48; 'hdpi' = 72; 'xhdpi' = 96; 'xxhdpi' = 144; 'xxxhdpi' = 192 }
foreach ($density in $densities.Keys) {
    $destination = Join-Path $raystoRoot "android/app/src/main/res/mipmap-$density/ic_launcher.png"
    Write-RaystoIcon $densities[$density] $destination $true $true
}
Write-Output "Generated $($written.Count) opaque iOS app icons, 3 launch images and 5 Android fallback icons."
