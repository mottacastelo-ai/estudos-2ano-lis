Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$W = 1024
$H = 1536
$OutDir = "C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\portugues\contos-encantamento"

$C = @{
  deep = [System.Drawing.ColorTranslator]::FromHtml("#E8430A")
  light = [System.Drawing.ColorTranslator]::FromHtml("#FB8C5A")
  cream = [System.Drawing.ColorTranslator]::FromHtml("#FFF4EF")
  gold = [System.Drawing.ColorTranslator]::FromHtml("#FFD166")
  brown = [System.Drawing.ColorTranslator]::FromHtml("#7A1F04")
  ink = [System.Drawing.Color]::FromArgb(25, 18, 14)
  sky = [System.Drawing.Color]::FromArgb(31, 56, 113)
  gray = [System.Drawing.Color]::FromArgb(132, 132, 132)
}

function New-Brush($color) { New-Object System.Drawing.SolidBrush($color) }
function New-Pen($color, $width = 4) {
  $p = New-Object System.Drawing.Pen($color, $width)
  $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $p.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $p.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $p
}
function Font($size, $style = [System.Drawing.FontStyle]::Regular) {
  New-Object System.Drawing.Font("Arial Rounded MT Bold", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function RoundedPath($x, $y, $w, $h, $r) {
  $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $gp.AddArc($x, $y, $d, $d, 180, 90)
  $gp.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $gp.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $gp.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $gp.CloseFigure()
  $gp
}

function BubblePath($x, $y, $w, $h, $tailX, $tailY) {
  $gp = RoundedPath $x $y $w $h 34
  $baseX = $x + $w * .56
  $baseY = $y + $h
  $tipX = $baseX + 10
  $tipY = $baseY + 42
  $gp.StartFigure()
  $gp.AddPolygon([System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new($baseX - 16, $baseY),
    [System.Drawing.PointF]::new($tipX, $tipY),
    [System.Drawing.PointF]::new($baseX + 16, $baseY)
  ))
  $gp
}

function CloudPath($x, $y, $w, $h) {
  $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @()
  for ($i = 0; $i -lt 28; $i++) {
    $a = 2 * [Math]::PI * $i / 28
    $rx = $w / 2 * (1 + 0.10 * [Math]::Sin(5 * $a))
    $ry = $h / 2 * (1 + 0.13 * [Math]::Cos(6 * $a))
    $pts += [System.Drawing.PointF]::new($x + $w / 2 + $rx * [Math]::Cos($a), $y + $h / 2 + $ry * [Math]::Sin($a))
  }
  $gp.AddClosedCurve([System.Drawing.PointF[]]$pts, .65)
  $gp
}

function JaggedPath($x, $y, $w, $h) {
  $pts = @()
  $cx = $x + $w / 2; $cy = $y + $h / 2
  for ($i = 0; $i -lt 32; $i++) {
    $a = 2 * [Math]::PI * $i / 32
    $r = if ($i % 2 -eq 0) { 1.0 } else { .76 }
    $pts += [System.Drawing.PointF]::new($cx + ($w / 2) * $r * [Math]::Cos($a), $cy + ($h / 2) * $r * [Math]::Sin($a))
  }
  $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
  $gp.AddPolygon([System.Drawing.PointF[]]$pts)
  $gp
}

function Draw-CenteredText($g, $text, $rect, $font, $brush, $align = "Center") {
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = if ($align -eq "Near") { [System.Drawing.StringAlignment]::Near } else { [System.Drawing.StringAlignment]::Center }
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $sf.Trimming = [System.Drawing.StringTrimming]::None
  $sf.FormatFlags = 0
  $g.DrawString($text, $font, $brush, $rect, $sf)
}

function Draw-Bubble($g, $text, $x, $y, $w, $h, $tailX, $tailY, $size = 22, $dotted = $false, $bold = $false) {
  $path = BubblePath $x $y $w $h $tailX $tailY
  $g.FillPath((New-Brush ([System.Drawing.Color]::White)), $path)
  $pen = New-Pen $C.ink 4
  if ($dotted) { $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot }
  $g.DrawPath($pen, $path)
  Draw-CenteredText $g $text ([System.Drawing.RectangleF]::new($x + 12, $y + 8, $w - 24, $h - 16)) (Font $size $(if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular })) (New-Brush $C.ink)
}

function Draw-Narrator($g, $text, $x, $y, $w, $h, $size = 21) {
  $rect = [System.Drawing.RectangleF]::new($x, $y, $w, $h)
  $g.FillRectangle((New-Brush $C.cream), $rect)
  $g.DrawRectangle((New-Pen $C.ink 4), $x, $y, $w, $h)
  Draw-CenteredText $g $text $rect (Font $size) (New-Brush $C.ink)
}

function Draw-Ribbon($g, $text, $x, $y, $w, $h, $size = 22) {
  $pts = [System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new($x, $y + $h / 2), [System.Drawing.PointF]::new($x + 18, $y),
    [System.Drawing.PointF]::new($x + $w - 18, $y), [System.Drawing.PointF]::new($x + $w, $y + $h / 2),
    [System.Drawing.PointF]::new($x + $w - 18, $y + $h), [System.Drawing.PointF]::new($x + 18, $y + $h)
  )
  $g.FillPolygon((New-Brush $C.deep), $pts)
  $g.DrawPolygon((New-Pen $C.brown 3), $pts)
  Draw-CenteredText $g $text ([System.Drawing.RectangleF]::new($x + 18, $y, $w - 36, $h)) (Font $size ([System.Drawing.FontStyle]::Bold)) (New-Brush ([System.Drawing.Color]::White))
}

function Draw-Panel($g, $x, $y, $w, $h, $fill) {
  $path = RoundedPath $x $y $w $h 22
  $g.FillPath((New-Brush $fill), $path)
  $g.DrawPath((New-Pen $C.ink 6), $path)
  $g.SetClip($path)
}
function Reset-Clip($g) { $g.ResetClip() }

function Draw-Star($g, $x, $y, $r, $color) {
  $pts = @()
  for ($i = 0; $i -lt 10; $i++) {
    $a = -[Math]::PI / 2 + $i * [Math]::PI / 5
    $rr = if ($i % 2 -eq 0) { $r } else { $r * .45 }
    $pts += [System.Drawing.PointF]::new($x + $rr * [Math]::Cos($a), $y + $rr * [Math]::Sin($a))
  }
  $g.FillPolygon((New-Brush $color), [System.Drawing.PointF[]]$pts)
}

function Draw-Notes($g, $x, $y, $count = 8) {
  $font = Font 30 ([System.Drawing.FontStyle]::Bold)
  $b = New-Brush $C.gold
  for ($i = 0; $i -lt $count; $i++) {
    $xx = $x + (($i * 43) % 190)
    $yy = $y + (($i * 67) % 150)
    $g.DrawString($(if ($i % 2) { "♪" } else { "♫" }), $font, $b, $xx, $yy)
    Draw-Star $g ($xx + 24) ($yy + 8) 8 $C.gold
  }
}

function Draw-Book($g, $x, $y, $w, $h, $open = $false) {
  $pen = New-Pen $C.brown 4
  if ($open) {
    $g.FillPie((New-Brush $C.cream), $x, $y, $w / 2 + 10, $h, 90, 180)
    $g.FillPie((New-Brush $C.cream), $x + $w / 2 - 10, $y, $w / 2 + 10, $h, 270, 180)
    $g.DrawArc($pen, $x, $y, $w / 2 + 10, $h, 90, 180)
    $g.DrawArc($pen, $x + $w / 2 - 10, $y, $w / 2 + 10, $h, 270, 180)
    $g.DrawLine($pen, $x + $w / 2, $y + 8, $x + $w / 2, $y + $h - 8)
  } else {
    $r = RoundedPath $x $y $w $h 12
    $g.FillPath((New-Brush $C.deep), $r)
    $g.DrawPath($pen, $r)
    Draw-Star $g ($x + $w / 2) ($y + $h / 2) 22 $C.gold
  }
}

function Draw-Lis($g, $x, $y, $s = 1.0, $pose = "happy") {
  $pen = New-Pen $C.ink (4 * $s)
  $skin = [System.Drawing.Color]::FromArgb(255, 193, 95)
  $hair = [System.Drawing.Color]::FromArgb(92, 43, 12)
  $g.FillEllipse((New-Brush $hair), $x - 42 * $s, $y - 98 * $s, 84 * $s, 95 * $s)
  $g.FillEllipse((New-Brush $skin), $x - 30 * $s, $y - 88 * $s, 60 * $s, 62 * $s)
  $g.DrawEllipse($pen, $x - 30 * $s, $y - 88 * $s, 60 * $s, 62 * $s)
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::White)), $x - 18 * $s, $y - 66 * $s, 14 * $s, 18 * $s)
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::White)), $x + 5 * $s, $y - 66 * $s, 14 * $s, 18 * $s)
  $g.FillEllipse((New-Brush $C.brown), $x - 13 * $s, $y - 61 * $s, 7 * $s, 9 * $s)
  $g.FillEllipse((New-Brush $C.brown), $x + 10 * $s, $y - 61 * $s, 7 * $s, 9 * $s)
  if ($pose -eq "sad") {
    $g.DrawArc($pen, $x - 13 * $s, $y - 38 * $s, 26 * $s, 14 * $s, 200, 140)
  } elseif ($pose -eq "surprise") {
    $g.FillEllipse((New-Brush ([System.Drawing.Color]::White)), $x - 7 * $s, $y - 42 * $s, 14 * $s, 18 * $s)
    $g.DrawEllipse($pen, $x - 7 * $s, $y - 42 * $s, 14 * $s, 18 * $s)
  } else {
    $g.FillPie((New-Brush ([System.Drawing.Color]::White)), $x - 16 * $s, $y - 45 * $s, 32 * $s, 23 * $s, 0, 180)
    $g.DrawArc($pen, $x - 16 * $s, $y - 45 * $s, 32 * $s, 23 * $s, 0, 180)
  }
  $g.FillRectangle((New-Brush $C.deep), $x - 28 * $s, $y - 25 * $s, 56 * $s, 48 * $s)
  $g.DrawRectangle($pen, $x - 28 * $s, $y - 25 * $s, 56 * $s, 48 * $s)
  $g.DrawString("♪", (Font (28 * $s) ([System.Drawing.FontStyle]::Bold)), (New-Brush $C.gold), $x - 10 * $s, $y - 21 * $s)
  $skirt = [System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new($x - 35 * $s, $y + 23 * $s),
    [System.Drawing.PointF]::new($x + 35 * $s, $y + 23 * $s),
    [System.Drawing.PointF]::new($x + 48 * $s, $y + 60 * $s),
    [System.Drawing.PointF]::new($x - 48 * $s, $y + 60 * $s)
  )
  $g.FillPolygon((New-Brush $C.cream), $skirt)
  $g.DrawPolygon($pen, $skirt)
  $g.DrawLine((New-Pen $C.light (4 * $s)), $x - 40 * $s, $y + 54 * $s, $x + 40 * $s, $y + 54 * $s)
  $g.DrawLine($pen, $x - 32 * $s, $y - 12 * $s, $x - 70 * $s, $y + 18 * $s)
  $g.DrawLine($pen, $x + 32 * $s, $y - 12 * $s, $x + 70 * $s, $y + 18 * $s)
  $g.DrawLine($pen, $x - 18 * $s, $y + 60 * $s, $x - 28 * $s, $y + 110 * $s)
  $g.DrawLine($pen, $x + 18 * $s, $y + 60 * $s, $x + 28 * $s, $y + 110 * $s)
  $g.DrawLine((New-Pen $C.light (5 * $s)), $x - 25 * $s, $y + 82 * $s, $x - 31 * $s, $y + 82 * $s)
  $g.DrawLine((New-Pen $C.light (5 * $s)), $x + 25 * $s, $y + 82 * $s, $x + 31 * $s, $y + 82 * $s)
  $g.FillEllipse((New-Brush $C.cream), $x - 46 * $s, $y + 105 * $s, 36 * $s, 15 * $s)
  $g.FillEllipse((New-Brush $C.cream), $x + 10 * $s, $y + 105 * $s, 36 * $s, 15 * $s)
  $g.DrawEllipse($pen, $x - 46 * $s, $y + 105 * $s, 36 * $s, 15 * $s)
  $g.DrawEllipse($pen, $x + 10 * $s, $y + 105 * $s, 36 * $s, 15 * $s)
}

function Draw-Flautim($g, $x, $y, $s = 1.0, $mood = "happy") {
  $pen = New-Pen $C.ink (4 * $s)
  $body = RoundedPath ($x - 22 * $s) ($y - 58 * $s) (44 * $s) (118 * $s) (20 * $s)
  $g.FillPath((New-Brush $C.deep), $body)
  $g.DrawPath($pen, $body)
  $g.FillEllipse((New-Brush $C.cream), $x - 28 * $s, $y - 78 * $s, 56 * $s, 42 * $s)
  $g.DrawEllipse($pen, $x - 28 * $s, $y - 78 * $s, 56 * $s, 42 * $s)
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::White)), $x - 24 * $s, $y - 105 * $s, 22 * $s, 30 * $s)
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::White)), $x + 2 * $s, $y - 105 * $s, 22 * $s, 30 * $s)
  $g.FillEllipse((New-Brush $C.ink), $x - 16 * $s, $y - 95 * $s, 8 * $s, 11 * $s)
  $g.FillEllipse((New-Brush $C.ink), $x + 10 * $s, $y - 95 * $s, 8 * $s, 11 * $s)
  $g.DrawArc((New-Pen $C.gold (5 * $s)), $x - 34 * $s, $y - 125 * $s, 24 * $s, 28 * $s, 200, 170)
  $g.DrawArc((New-Pen $C.gold (5 * $s)), $x + 10 * $s, $y - 125 * $s, 24 * $s, 28 * $s, 170, 170)
  foreach ($yy in @(-22, 10, 40)) {
    $g.FillEllipse((New-Brush $C.brown), $x - 8 * $s, $y + $yy * $s, 16 * $s, 16 * $s)
  }
  $g.DrawLine((New-Pen $C.gold (5 * $s)), $x - 22 * $s, $y - 15 * $s, $x - 58 * $s, $y - 36 * $s)
  $g.DrawLine((New-Pen $C.gold (5 * $s)), $x + 22 * $s, $y - 15 * $s, $x + 58 * $s, $y - 36 * $s)
  $g.DrawArc((New-Pen $C.gold (6 * $s)), $x - 28 * $s, $y + 42 * $s, 55 * $s, 55 * $s, 350, 300)
  $g.DrawLine((New-Pen $C.deep (5 * $s)), $x - 22 * $s, $y - 4 * $s, $x + 22 * $s, $y - 8 * $s)
  Draw-Notes $g ($x + 26 * $s) ($y + 12 * $s) 4
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(50, 255, 209, 102))), $x - 40 * $s, $y + 70 * $s, 80 * $s, 22 * $s)
}

function Draw-SceneReading($g, $x, $y, $w, $h, $night = $true) {
  $g.FillRectangle((New-Brush $C.cream), $x, $y, $w, $h)
  $g.FillRectangle((New-Brush ([System.Drawing.Color]::FromArgb(146, 86, 42))), $x + 26, $y + 55, 136, 260)
  for ($i = 0; $i -lt 13; $i++) {
    $col = if ($i % 3 -eq 0) { $C.deep } elseif ($i % 3 -eq 1) { $C.light } else { $C.gold }
    $g.FillRectangle((New-Brush $col), $x + 38 + (($i % 5) * 23), $y + 75 + ([Math]::Floor($i / 5) * 70), 16, 48)
  }
  $g.FillEllipse((New-Brush $C.light), $x + 165, $y + $h - 100, 170, 58)
  $g.FillRectangle((New-Brush $(if ($night) { $C.sky } else { [System.Drawing.Color]::FromArgb(245, 180, 120) })), $x + $w - 142, $y + 45, 92, 86)
  $g.DrawRectangle((New-Pen $C.brown 4), $x + $w - 142, $y + 45, 92, 86)
  Draw-Star $g ($x + $w - 95) ($y + 78) 7 $C.gold
  $g.FillEllipse((New-Brush $C.gold), $x + $w - 210, $y + 255, 38, 38)
  $g.DrawLine((New-Pen $C.brown 5), $x + $w - 191, $y + 292, $x + $w - 191, $y + 335)
}

function Draw-MedievalTown($g, $x, $y, $w, $h, $gray = $false) {
  $bg = if ($gray) { [System.Drawing.Color]::FromArgb(222, 220, 211) } else { [System.Drawing.Color]::FromArgb(255, 240, 210) }
  $g.FillRectangle((New-Brush $bg), $x, $y, $w, $h)
  for ($i = 0; $i -lt 5; $i++) {
    $bx = $x + 25 + $i * 88
    $by = $y + 85 + (($i % 2) * 25)
    $g.FillRectangle((New-Brush ([System.Drawing.Color]::FromArgb(166, 100, 52))), $bx, $by, 70, 95)
    $roof = [System.Drawing.PointF[]]@([System.Drawing.PointF]::new($bx - 10, $by), [System.Drawing.PointF]::new($bx + 35, $by - 42), [System.Drawing.PointF]::new($bx + 80, $by))
    $g.FillPolygon((New-Brush $C.deep), $roof)
    $g.DrawPolygon((New-Pen $C.brown 3), $roof)
  }
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(145, 145, 145))), $x + $w / 2 - 42, $y + 245, 84, 40)
  $g.DrawEllipse((New-Pen $C.ink 4), $x + $w / 2 - 42, $y + 245, 84, 40)
}

function Draw-Rat($g, $x, $y, $s = 1.0) {
  $gray = [System.Drawing.Color]::FromArgb(138, 142, 148)
  $g.FillEllipse((New-Brush $gray), $x, $y, 34 * $s, 22 * $s)
  $g.FillEllipse((New-Brush $gray), $x + 24 * $s, $y + 2 * $s, 18 * $s, 16 * $s)
  $g.FillEllipse((New-Brush $C.ink), $x + 36 * $s, $y + 8 * $s, 4 * $s, 4 * $s)
  $g.DrawArc((New-Pen $gray (3 * $s)), $x - 24 * $s, $y + 9 * $s, 30 * $s, 20 * $s, 190, 160)
}

function Draw-MiniPerson($g, $x, $y, $s = 1.0, $child = $false) {
  $skin = [System.Drawing.Color]::FromArgb(255, 196, 118)
  $g.FillEllipse((New-Brush $skin), $x - 10 * $s, $y - 44 * $s, 20 * $s, 20 * $s)
  $g.FillRectangle((New-Brush $(if ($child) { $C.light } else { $C.brown })), $x - 13 * $s, $y - 24 * $s, 26 * $s, 42 * $s)
  $g.DrawLine((New-Pen $C.ink (3 * $s)), $x - 12 * $s, $y + 18 * $s, $x - 22 * $s, $y + 42 * $s)
  $g.DrawLine((New-Pen $C.ink (3 * $s)), $x + 12 * $s, $y + 18 * $s, $x + 22 * $s, $y + 42 * $s)
}

function Draw-PageBase($title) {
  $bmp = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear($C.cream)
  Draw-CenteredText $g $title ([System.Drawing.RectangleF]::new(0, 14, $W, 50)) (Font 34 ([System.Drawing.FontStyle]::Bold)) (New-Brush $C.deep)
  [pscustomobject]@{ Bitmap = $bmp; Graphics = $g }
}

function Save-Page($page, $name) {
  $path = Join-Path $OutDir $name
  $page.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $page.Graphics.Dispose()
  $page.Bitmap.Dispose()
  Write-Output $path
}

$PX = @(32, 524, 32, 524)
$PY = @(78, 78, 802, 802)
$PW = 468
$PH = 690

function Page1 {
  $p = Draw-PageBase "Contos de Encantamento"
  $g = $p.Graphics
  Draw-Panel $g $PX[0] $PY[0] $PW $PH $C.cream
  Draw-SceneReading $g $PX[0] $PY[0] $PW $PH $true
  Draw-Book $g 132 213 64 82 $false
  Draw-Notes $g 136 205 2
  Draw-Lis $g 310 505 .95 "surprise"
  Draw-Narrator $g "O livro se abriu sozinho." 55 100 235 54
  Draw-Bubble $g "Que livro é esse`nbrilhando na estante?" 205 130 245 92 345 405 20
  Reset-Clip $g

  Draw-Panel $g $PX[1] $PY[1] $PW $PH ([System.Drawing.Color]::FromArgb(255, 236, 190))
  Draw-SceneReading $g $PX[1] $PY[1] $PW $PH $true
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(95, 255, 209, 102))), 645, 160, 270, 250)
  Draw-Book $g 715 255 105 72 $true
  Draw-Flautim $g 795 345 .9 "happy"
  Draw-Lis $g 695 560 .9 "surprise"
  Draw-Bubble $g "Era uma vez...`nadivinha quem?" 585 118 230 84 790 270 21
  Draw-Bubble $g "Uma flauta falante!`nQue legal!" 765 505 192 86 728 575 20
  Reset-Clip $g

  Draw-Panel $g $PX[2] $PY[2] $PW $PH $C.cream
  Draw-SceneReading $g $PX[2] $PY[2] $PW $PH $false
  Draw-Lis $g 180 1250 .92 "happy"
  Draw-Flautim $g 380 1110 .78 "happy"
  Draw-Book $g 147 1215 76 52 $true
  Draw-Ribbon $g "ERA UMA VEZ..." 92 875 310 55 26
  Draw-Ribbon $g "HÁ MUITO, MUITO TEMPO..." 60 950 380 55 23
  $g.DrawString("⌛  🏰", (Font 36 ([System.Drawing.FontStyle]::Bold)), (New-Brush $C.gold), 205, 1015)
  Draw-Bubble $g "Todo conto começa assim:`nEra uma vez!" 255 1160 215 93 382 1120 19
  Draw-Bubble $g "Isso quer dizer passado`nbem distante?" 55 1060 245 92 180 1180 19
  Reset-Clip $g

  Draw-Panel $g $PX[3] $PY[3] $PW $PH ([System.Drawing.Color]::FromArgb(255, 238, 205))
  Draw-SceneReading $g $PX[3] $PY[3] $PW $PH $false
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(95, 255, 209, 102))), 575, 900, 370, 250)
  $g.DrawString("♛   LOBO   CESTA   DRAGÃO   ♪", (Font 22 ([System.Drawing.FontStyle]::Bold)), (New-Brush $C.gold), 595, 995)
  Draw-Ribbon $g "PERSONAGENS" 630 1090 260 48 22
  Draw-Lis $g 730 1320 1.0 "happy"
  Draw-Flautim $g 890 1210 .75 "happy"
  Draw-Bubble $g "Personagens são quem`nvive a história!" 560 1160 250 92 878 1175 19
  Draw-Bubble $g "Reis, bichos, crianças...`ne flautas mágicas!" 765 1370 230 82 745 1340 17
  Reset-Clip $g
  Save-Page $p "hq-contos-encantamento-pg1.png"
}

function Page2 {
  $p = Draw-PageBase "O conflito de Hamelin"
  $g = $p.Graphics
  Draw-Panel $g $PX[0] $PY[0] $PW $PH ([System.Drawing.Color]::FromArgb(255, 242, 215))
  Draw-SceneReading $g $PX[0] $PY[0] $PW $PH $true
  $g.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(120, 255, 209, 102))), 160, 165, 230, 300)
  Draw-MedievalTown $g 205 195 210 190 $false
  Draw-Lis $g 220 520 .9 "happy"
  Draw-Book $g 170 420 70 50 $false
  Draw-Flautim $g 360 345 .75 "happy"
  Draw-Bubble $g "Segura essa nota, Lis!`nVamos entrar!" 55 120 230 86 350 285 19
  Draw-Bubble $g "Há muito, muito tempo...`nem Hamelin!" 245 565 215 82 238 520 18
  Reset-Clip $g

  Draw-Panel $g $PX[1] $PY[1] $PW $PH ([System.Drawing.Color]::FromArgb(223, 225, 222))
  Draw-MedievalTown $g $PX[1] $PY[1] $PW $PH $true
  for ($i = 0; $i -lt 28; $i++) { Draw-Rat $g (545 + (($i * 53) % 420)) (350 + (($i * 37) % 250)) .8 }
  Draw-Lis $g 700 590 .85 "surprise"
  Draw-Flautim $g 870 525 .75 "surprise"
  Draw-MiniPerson $g 895 330 .8 $false; Draw-MiniPerson $g 930 335 .8 $false; Draw-MiniPerson $g 850 340 .8 $false
  $g.FillRectangle((New-Brush $C.brown), 842, 350, 40, 28); Draw-Notes $g 845 340 1
  Draw-Narrator $g "A cidade amanheceu`ninfestada de ratos." 545 100 245 70 18
  Draw-Bubble $g "Os ratos comem`ntoda a comida!" 565 195 215 82 700 465 19
  Draw-Bubble $g "Um pote de ouro`npara quem resolver!" 790 205 195 86 885 340 18
  Reset-Clip $g

  Draw-Panel $g $PX[2] $PY[2] $PW $PH ([System.Drawing.Color]::FromArgb(255, 238, 202))
  Draw-MedievalTown $g $PX[2] $PY[2] $PW $PH $false
  Draw-MiniPerson $g 255 1045 1.45 $false
  $g.DrawString("♪", (Font 44), (New-Brush $C.gold), 250, 965)
  $g.DrawBezier((New-Pen $C.gold 8), 300, 1010, 340, 950, 420, 1010, 465, 930)
  for ($i = 0; $i -lt 18; $i++) { Draw-Rat $g (60 + $i * 21) (1230 + (($i % 3) * 22)) .68 }
  Draw-Lis $g 155 1400 .72 "surprise"
  Draw-Flautim $g 325 1310 .62 "happy"
  Draw-Ribbon $g "ELEMENTO MÁGICO" 245 895 205 46 18
  Draw-Bubble $g "A flauta é o`nelemento mágico!" 55 860 215 82 320 1260 18
  Draw-Bubble $g "Os ratos seguem a`nmelodia encantada!" 225 1350 235 82 155 1360 17
  Reset-Clip $g

  Draw-Panel $g $PX[3] $PY[3] $PW $PH ([System.Drawing.Color]::FromArgb(255, 236, 190))
  $star = JaggedPath 590 870 340 180
  $g.FillPath((New-Brush $C.light), $star); $g.DrawPath((New-Pen $C.brown 5), $star)
  Draw-Ribbon $g "CONFLITO" 625 925 270 60 34
  Draw-Rat $g 625 1105 1.4
  $g.FillEllipse((New-Brush $C.gold), 760, 1100, 75, 52); $g.DrawString("X", (Font 46 ([System.Drawing.FontStyle]::Bold)), (New-Brush ([System.Drawing.Color]::Red)), 840, 1098)
  Draw-Flautim $g 760 1230 .85 "happy"
  Draw-Lis $g 890 1410 .73 "happy"
  Draw-Bubble $g "Esse problemão tem`nnome: CONFLITO!" 545 1028 255 88 760 1160 18
  Draw-Bubble $g "Conflito complica a`nvida das personagens." 755 1175 220 86 795 1220 17
  Draw-Bubble $g "Todo conto tem um`nproblema, né?" 550 1350 225 82 885 1360 17
  Reset-Clip $g
  Save-Page $p "hq-contos-encantamento-pg2.png"
}

function Page3 {
  $p = Draw-PageBase "O desfecho"
  $g = $p.Graphics
  Draw-Panel $g $PX[0] $PY[0] $PW $PH ([System.Drawing.Color]::FromArgb(235, 210, 178))
  $g.FillRectangle((New-Brush ([System.Drawing.Color]::FromArgb(136, 82, 43))), 55, 230, 410, 135)
  $g.FillRectangle((New-Brush $C.brown), 230, 250, 90, 55); Draw-Notes $g 250 248 1
  for ($i = 0; $i -lt 3; $i++) { Draw-MiniPerson $g (105 + $i * 80) 430 1.2 $false }
  Draw-MiniPerson $g 390 455 1.25 $false
  Draw-Lis $g 120 660 .68 "sad"
  Draw-Flautim $g 220 610 .58 "sad"
  Draw-Bubble $g "Não vamos pagar`nesse ouro todo!" 65 95 220 82 145 385 18
  Draw-Bubble $g "Que avareza! Prometeram`ne não cumpriram." 238 540 222 92 220 590 17
  Reset-Clip $g

  Draw-Panel $g $PX[1] $PY[1] $PW $PH ([System.Drawing.Color]::FromArgb(230, 205, 170))
  Draw-MedievalTown $g $PX[1] $PY[1] $PW $PH $true
  $g.DrawCurve((New-Pen $C.brown 16), [System.Drawing.PointF[]]@([System.Drawing.PointF]::new(965, 760), [System.Drawing.PointF]::new(850, 575), [System.Drawing.PointF]::new(705, 470), [System.Drawing.PointF]::new(590, 390)))
  Draw-MiniPerson $g 905 410 1.1 $false
  for ($i = 0; $i -lt 8; $i++) { Draw-MiniPerson $g (855 - $i * 32) (470 - $i * 17) .75 $true }
  Draw-Lis $g 645 680 .7 "sad"
  Draw-Flautim $g 760 600 .55 "sad"
  Draw-Narrator $g "As crianças seguiram o`nflautista para longe." 545 100 260 70 17
  Draw-Bubble $g "A cidade ficou triste`ne silenciosa..." 720 650 245 82 640 640 18
  Reset-Clip $g

  Draw-Panel $g $PX[2] $PY[2] $PW $PH ([System.Drawing.Color]::FromArgb(255, 239, 204))
  Draw-MedievalTown $g $PX[2] $PY[2] $PW $PH $false
  Draw-MiniPerson $g 245 1080 1.25 $false
  Draw-MiniPerson $g 110 1260 .95 $false; Draw-MiniPerson $g 160 1270 .95 $false
  $g.FillRectangle((New-Brush $C.brown), 305, 1225, 82, 44); Draw-Notes $g 325 1220 1
  Draw-Lis $g 205 1435 .72 "happy"
  Draw-Flautim $g 338 1375 .58 "happy"
  Draw-Ribbon $g "PROMESSA" 150 1120 220 48 18
  Draw-Bubble $g "Nunca mais descumpram`numa promessa!" 55 870 245 82 245 1040 18
  Draw-Bubble $g "Prometemos! Devolva nossas`ncrianças, por favor!" 210 1285 245 88 165 1240 16
  Reset-Clip $g

  Draw-Panel $g $PX[3] $PY[3] $PW $PH ([System.Drawing.Color]::FromArgb(255, 238, 198))
  Draw-MedievalTown $g $PX[3] $PY[3] $PW $PH $false
  Draw-Ribbon $g "DESFECHO" 610 850 300 62 34
  Draw-Ribbon $g "E VIVERAM FELIZES PARA SEMPRE" 570 920 380 44 18
  for ($i = 0; $i -lt 7; $i++) { Draw-MiniPerson $g (590 + $i * 50) (1125 + (($i % 2) * 35)) .85 $true }
  Draw-MiniPerson $g 915 1120 1.1 $false
  $g.FillRectangle((New-Brush $C.brown), 850, 1180, 70, 45); Draw-Notes $g 860 1170 1
  Draw-Lis $g 705 1375 .86 "happy"
  Draw-Flautim $g 895 1320 .67 "happy"
  Draw-Ribbon $g "início" 545 1430 90 34 15
  Draw-Ribbon $g "conflito" 690 1430 110 34 15
  Draw-Ribbon $g "desfecho" 850 1430 115 34 15
  $g.DrawString("→", (Font 30), (New-Brush $C.gold), 645, 1430)
  $g.DrawString("→", (Font 30), (New-Brush $C.gold), 810, 1430)
  Draw-Bubble $g "Conflito resolvido?`nIsso é o DESFECHO!" 545 985 245 88 845 1280 17
  Draw-Bubble $g "E viveram felizes`npara sempre!" 780 1218 205 82 710 1320 17
  Draw-Bubble $g "...até a próxima`npágina!" 545 1265 185 76 885 1285 16
  Reset-Clip $g
  Save-Page $p "hq-contos-encantamento-pg3.png"
}

function Page4 {
  $p = Draw-PageBase "Os balões da HQ"
  $g = $p.Graphics
  Draw-Panel $g $PX[0] $PY[0] $PW $PH $C.cream
  Draw-SceneReading $g $PX[0] $PY[0] $PW $PH $false
  Draw-Book $g 225 595 92 62 $false
  Draw-Flautim $g 240 350 .82 "happy"
  Draw-Lis $g 360 585 .82 "happy"
  foreach ($i in 0..4) {
    $g.DrawEllipse((New-Pen $C.gold 4), 95 + $i * 65, 185 - (($i % 2) * 40), 58, 48)
  }
  Draw-Bubble $g "Agora os balões da`nhistória em quadrinhos!" 55 100 260 84 240 260 18
  Draw-Bubble $g "Bolhas douradas virando`nbalões? Uau!" 225 430 235 82 360 520 18
  Reset-Clip $g

  Draw-Panel $g $PX[1] $PY[1] $PW $PH $C.cream
  $smooth = BubblePath 555 195 185 125 630 365
  $dotted = BubblePath 795 195 185 125 870 365
  $g.FillPath((New-Brush ([System.Drawing.Color]::White)), $smooth); $g.DrawPath((New-Pen $C.ink 5), $smooth)
  $penDot = New-Pen $C.ink 5; $penDot.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot
  $g.FillPath((New-Brush ([System.Drawing.Color]::White)), $dotted); $g.DrawPath($penDot, $dotted)
  Draw-Ribbon $g "BALÃO DE FALA" 555 335 185 42 17
  Draw-Ribbon $g "BALÃO DE COCHICHO" 780 335 210 42 15
  Draw-Lis $g 760 620 .78 "happy"
  Draw-Flautim $g 770 175 .52 "happy"
  Draw-Bubble $g "Contorno liso com rabicho:`nbalão de fala!" 545 430 235 82 690 570 16
  Draw-Bubble $g "Pontilhado é cochicho,`nbem baixinho." 765 455 220 82 835 350 15 $true
  Reset-Clip $g

  Draw-Panel $g $PX[2] $PY[2] $PW $PH $C.cream
  $cloud = CloudPath 60 910 205 125
  $jag = JaggedPath 285 900 185 140
  $g.FillPath((New-Brush ([System.Drawing.Color]::White)), $cloud); $g.DrawPath((New-Pen $C.ink 5), $cloud)
  $g.FillPath((New-Brush ([System.Drawing.Color]::White)), $jag); $g.DrawPath((New-Pen $C.ink 5), $jag)
  Draw-Ribbon $g "BALÃO DE PENSAMENTO" 45 1050 240 42 14
  Draw-Ribbon $g "BALÃO DE GRITO" 302 1050 160 42 14
  Draw-CenteredText $g "SERRILHADO É`nBALÃO DE GRITO!" ([System.Drawing.RectangleF]::new(306, 925, 158, 92)) (Font 15 ([System.Drawing.FontStyle]::Bold)) (New-Brush $C.ink)
  foreach ($r in 0..2) { $g.FillEllipse((New-Brush ([System.Drawing.Color]::White)), 155 + $r * 22, 1120 + $r * 25, 20 - $r * 3, 20 - $r * 3); $g.DrawEllipse((New-Pen $C.ink 3), 155 + $r * 22, 1120 + $r * 25, 20 - $r * 3, 20 - $r * 3) }
  Draw-Lis $g 150 1390 .72 "happy"
  Draw-Flautim $g 365 1325 .67 "surprise"
  Draw-Bubble $g "Nuvem com bolinhas:`nbalão de pensamento!" 45 1190 240 82 165 1330 16
  Reset-Clip $g

  Draw-Panel $g $PX[3] $PY[3] $PW $PH $C.cream
  Draw-SceneReading $g $PX[3] $PY[3] $PW $PH $false
  Draw-Narrator $g "Retângulo sem rabicho:`no narrador conta." 565 855 380 82 20
  Draw-Ribbon $g "BALÃO DE NARRADOR" 640 945 230 42 16
  Draw-Book $g 720 1265 92 62 $false
  Draw-Lis $g 700 1320 .86 "happy"
  Draw-Flautim $g 885 1260 .68 "happy"
  Draw-Bubble $g "Vem treinar os balões`nno portal!" 545 1125 235 82 700 1260 18
  Draw-Bubble $g "E viveram felizes`npara sempre!" 780 1090 205 82 885 1210 17
  $x0 = 560
  $mini1 = BubblePath $x0 1430 58 32 ($x0 + 34) 1475; $g.DrawPath((New-Pen $C.ink 2), $mini1)
  $mini2 = BubblePath ($x0 + 78) 1430 58 32 ($x0 + 112) 1475; $pd = New-Pen $C.ink 2; $pd.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot; $g.DrawPath($pd, $mini2)
  $g.DrawPath((New-Pen $C.ink 2), (CloudPath ($x0 + 156) 1430 58 32))
  $g.DrawPath((New-Pen $C.ink 2), (JaggedPath ($x0 + 234) 1428 58 36))
  $g.DrawRectangle((New-Pen $C.ink 2), $x0 + 312, 1430, 58, 32)
  Reset-Clip $g
  Save-Page $p "hq-contos-encantamento-pg4.png"
}

Page1
Page2
Page3
Page4
