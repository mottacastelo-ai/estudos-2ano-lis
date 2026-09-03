Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$OutDir = "C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\historia\albuns-fotografia"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$W = 1024
$H = 1536
$Black = [System.Drawing.Color]::FromArgb(20,20,20)
$Violet = [System.Drawing.Color]::FromArgb(168,85,247)
$LightViolet = [System.Drawing.Color]::FromArgb(208,142,248)
$Cream = [System.Drawing.Color]::FromArgb(245,234,214)
$Sepia = [System.Drawing.Color]::FromArgb(139,90,43)
$Leather = [System.Drawing.Color]::FromArgb(92,58,33)
$Gold = [System.Drawing.Color]::FromArgb(212,175,55)
$Wood = [System.Drawing.Color]::FromArgb(132,83,42)
$Skin = [System.Drawing.Color]::FromArgb(255,190,90)
$Hair = [System.Drawing.Color]::FromArgb(92,45,18)
$Denim = [System.Drawing.Color]::FromArgb(80,155,210)
$Lilac = [System.Drawing.Color]::FromArgb(190,150,245)

function Brush($c) { New-Object System.Drawing.SolidBrush($c) }
function Pen($c, [float]$w=3) {
  $p = New-Object System.Drawing.Pen($c, $w)
  $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  return $p
}
function FontA([float]$size, [string]$style="Regular") {
  $fs = [System.Drawing.FontStyle]::Regular
  if ($style -eq "Bold") { $fs = [System.Drawing.FontStyle]::Bold }
  if ($style -eq "Italic") { $fs = [System.Drawing.FontStyle]::Italic }
  return New-Object System.Drawing.Font("Arial", $size, $fs, [System.Drawing.GraphicsUnit]::Pixel)
}
function U([string]$text) {
  return [System.Text.RegularExpressions.Regex]::Unescape($text)
}
function RoundedPath([float]$x,[float]$y,[float]$w,[float]$h,[float]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x,$y,$d,$d,180,90)
  $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
  $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90)
  $p.AddArc($x,$y+$h-$d,$d,$d,90,90)
  $p.CloseFigure()
  return $p
}
function FillRound($g,$rect,$r,$fill,$stroke=$Black,$sw=3) {
  $path = RoundedPath $rect.X $rect.Y $rect.Width $rect.Height $r
  $g.FillPath((Brush $fill), $path)
  if ($stroke) { $g.DrawPath((Pen $stroke $sw), $path) }
}
function TextFit($g,[string]$text,$rect,[float]$max,[float]$min=15,[string]$style="Bold",[string]$align="Center") {
  $fmt = New-Object System.Drawing.StringFormat
  $fmt.Alignment = if ($align -eq "Near") { [System.Drawing.StringAlignment]::Near } else { [System.Drawing.StringAlignment]::Center }
  $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
  $fmt.Trimming = [System.Drawing.StringTrimming]::None
  $fmt.FormatFlags = 0
  for ($s=$max; $s -ge $min; $s-=1) {
    $f = FontA $s $style
    $sz = $g.MeasureString($text, $f, $rect.Size, $fmt)
    if ($sz.Width -le $rect.Width -and $sz.Height -le $rect.Height) {
      $g.DrawString($text, $f, (Brush $Black), $rect, $fmt)
      return
    }
  }
  $g.DrawString($text, (FontA $min $style), (Brush $Black), $rect, $fmt)
}
function Bubble($g,[string]$text,[int]$x,[int]$y,[int]$w,[int]$h,[int]$tx,[int]$ty,[float]$fs=25) {
  $rect = [System.Drawing.RectangleF]::new($x,$y,$w,$h)
  $tail = New-Object System.Drawing.Point[] 3
  $tail[0] = [System.Drawing.Point]::new($x+[int]($w*.42),$y+$h-2)
  $tail[1] = [System.Drawing.Point]::new($x+[int]($w*.58),$y+$h-2)
  $tail[2] = [System.Drawing.Point]::new($tx,$ty)
  $g.FillPolygon((Brush ([System.Drawing.Color]::White)), $tail)
  $g.DrawPolygon((Pen $Black 3), $tail)
  FillRound $g $rect 25 ([System.Drawing.Color]::White) $Black 3
  $inner = [System.Drawing.RectangleF]::new($x+14,$y+8,$w-28,$h-16)
  TextFit $g $text $inner $fs 14 "Bold"
}
function Narrator($g,[string]$text,[int]$x,[int]$y,[int]$w,[int]$h) {
  $rect = [System.Drawing.RectangleF]::new($x,$y,$w,$h)
  FillRound $g $rect 10 $Cream $Black 3
  TextFit $g $text ([System.Drawing.RectangleF]::new($x+10,$y+4,$w-20,$h-8)) 23 14 "Bold"
}
function CardText($g,[string]$text,[int]$x,[int]$y,[int]$w,[int]$h) {
  $rect = [System.Drawing.RectangleF]::new($x,$y,$w,$h)
  FillRound $g $rect 12 $LightViolet $Black 3
  TextFit $g $text ([System.Drawing.RectangleF]::new($x+8,$y+3,$w-16,$h-6)) 25 15 "Bold"
}
function NewCanvas() {
  $bmp = New-Object System.Drawing.Bitmap($W,$H,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear($Cream)
  return @($bmp,$g)
}
function SaveCanvas($bmp,$g,[string]$path) {
  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}
function Panel($g,[int]$x,[int]$y,[int]$w,[int]$h,[System.Drawing.Color]$fill) {
  $rect = [System.Drawing.RectangleF]::new($x,$y,$w,$h)
  $g.FillRectangle((Brush $fill), $rect)
  $g.DrawRectangle((Pen $Black 6), $x,$y,$w,$h)
}
function AtticBg($g,[int]$x,[int]$y,[int]$w,[int]$h) {
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(230,202,158))), $x,$y,$w,$h)
  for ($i=0; $i -lt 5; $i++) { $g.DrawLine((Pen $Wood 4), $x+20+$i*100,$y+10,$x+80+$i*80,$y+120) }
  $g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(255,230,150))), $x+$w-125,$y+28,82,82)
  $g.DrawEllipse((Pen $Black 4), $x+$w-125,$y+28,82,82)
  $beam = New-Object System.Drawing.Drawing2D.GraphicsPath
  $beam.AddPolygon([System.Drawing.Point[]]@(
    ([System.Drawing.Point]::new($x+$w-85,$y+105)),
    ([System.Drawing.Point]::new($x+$w-5,$y+$h-20)),
    ([System.Drawing.Point]::new($x+$w-205,$y+$h-20)),
    ([System.Drawing.Point]::new($x+$w-125,$y+105))
  ))
  $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95,255,231,150))), $beam)
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(118,76,38))), $x,$y+$h-58,$w,58)
  for ($lx=$x; $lx -lt $x+$w; $lx+=45) { $g.DrawLine((Pen $Leather 1), $lx,$y+$h-58,$lx+25,$y+$h) }
}
function DrawTrunk($g,[int]$x,[int]$y,[float]$s,[bool]$open=$false) {
  $w=[int](150*$s); $h=[int](80*$s)
  if ($open) {
    $g.FillRectangle((Brush $Wood), $x,$y-[int](45*$s),$w,[int](45*$s))
    $g.DrawRectangle((Pen $Black (3*$s)), $x,$y-[int](45*$s),$w,[int](45*$s))
  }
  FillRound $g ([System.Drawing.RectangleF]::new($x,$y,$w,$h)) (12*$s) $Wood $Black (3*$s)
  $g.DrawLine((Pen $Leather (4*$s)), $x+[int](18*$s),$y,$x+[int](18*$s),$y+$h)
  $g.DrawLine((Pen $Leather (4*$s)), $x+$w-[int](18*$s),$y,$x+$w-[int](18*$s),$y+$h)
  $g.FillRectangle((Brush $Gold), $x+[int](65*$s),$y+[int](25*$s),[int](25*$s),[int](18*$s))
  $g.DrawRectangle((Pen $Black (2*$s)), $x+[int](65*$s),$y+[int](25*$s),[int](25*$s),[int](18*$s))
}
function DrawAlbum($g,[int]$x,[int]$y,[float]$s,[bool]$open=$false) {
  $w=[int](150*$s); $h=[int](105*$s)
  if ($open) {
    FillRound $g ([System.Drawing.RectangleF]::new($x,$y,$w,$h)) (8*$s) ([System.Drawing.Color]::FromArgb(248,239,211)) $Black (3*$s)
    $g.DrawLine((Pen $Leather (4*$s)), $x+$w/2,$y+4,$x+$w/2,$y+$h-4)
    for ($i=0; $i -lt 4; $i++) {
      $px=$x+[int](15*$s)+($i%2)*[int](72*$s); $py=$y+[int](15*$s)+[math]::Floor($i/2)*[int](42*$s)
      $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(160,117,76))), $px,$py,[int](46*$s),[int](30*$s))
      $g.DrawRectangle((Pen ([System.Drawing.Color]::White) (3*$s)), $px,$py,[int](46*$s),[int](30*$s))
    }
  } else {
    FillRound $g ([System.Drawing.RectangleF]::new($x,$y,$w,$h)) (10*$s) $Leather $Black (3*$s)
    $g.DrawLine((Pen $Lilac (8*$s)), $x+[int](20*$s),$y,$x+[int](20*$s),$y+$h)
    $g.DrawString("*", (FontA (24*$s) "Bold"), (Brush $Gold), $x+$w-[int](42*$s), $y+[int](28*$s))
  }
}
function DrawPhoto($g,[int]$x,[int]$y,[int]$w,[int]$h,[string]$kind="family") {
  $g.FillRectangle((Brush ([System.Drawing.Color]::White)), $x,$y,$w,$h)
  $g.DrawRectangle((Pen $Black 2), $x,$y,$w,$h)
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(178,130,78))), $x+7,$y+7,$w-14,$h-14)
  if ($kind -eq "posed") {
    for ($i=0; $i -lt 5; $i++) { DrawTinyPerson $g ($x+25+$i*22) ($y+$h-22) 0.45 $true }
  } elseif ($kind -eq "candid") {
    for ($i=0; $i -lt 4; $i++) { DrawTinyPerson $g ($x+25+$i*28) ($y+$h-20-[int](($i%2)*12)) 0.45 $false }
    $g.DrawEllipse((Pen $Black 2), $x+$w-40,$y+$h-40,24,14)
  } else {
    $g.FillRectangle((Brush $Wood), $x+12,$y+28,$w-24,$h-36)
    for ($i=0; $i -lt 4; $i++) { DrawTinyPerson $g ($x+28+$i*26) ($y+$h-24) 0.42 $true }
  }
}
function DrawTinyPerson($g,[int]$x,[int]$y,[float]$s,[bool]$stiff) {
  $g.FillEllipse((Brush $Skin), $x-[int](10*$s),$y-[int](58*$s),[int](20*$s),[int](20*$s))
  $g.DrawEllipse((Pen $Black (2*$s)), $x-[int](10*$s),$y-[int](58*$s),[int](20*$s),[int](20*$s))
  $g.FillRectangle((Brush $Violet), $x-[int](9*$s),$y-[int](38*$s),[int](18*$s),[int](28*$s))
  $g.DrawRectangle((Pen $Black (2*$s)), $x-[int](9*$s),$y-[int](38*$s),[int](18*$s),[int](28*$s))
  if ($stiff) {
    $g.DrawLine((Pen $Black (2*$s)), $x-[int](9*$s),$y-[int](30*$s),$x-[int](19*$s),$y-[int](18*$s))
    $g.DrawLine((Pen $Black (2*$s)), $x+[int](9*$s),$y-[int](30*$s),$x+[int](19*$s),$y-[int](18*$s))
  } else {
    $g.DrawLine((Pen $Black (2*$s)), $x-[int](9*$s),$y-[int](30*$s),$x-[int](23*$s),$y-[int](42*$s))
    $g.DrawLine((Pen $Black (2*$s)), $x+[int](9*$s),$y-[int](30*$s),$x+[int](22*$s),$y-[int](45*$s))
  }
  $g.DrawLine((Pen $Black (2*$s)), $x-[int](4*$s),$y-[int](10*$s),$x-[int](12*$s),$y)
  $g.DrawLine((Pen $Black (2*$s)), $x+[int](4*$s),$y-[int](10*$s),$x+[int](12*$s),$y)
}
function DrawLis($g,[int]$x,[int]$y,[float]$s,[string]$pose="happy") {
  $lw = [math]::Max(2, [int](4*$s))
  if ($pose -eq "jump") { $y -= [int](18*$s) }
  $headW=[int](68*$s); $headH=[int](72*$s)
  $g.FillEllipse((Brush $Hair), $x-[int](44*$s),$y-[int](178*$s),[int](88*$s),[int](95*$s))
  $g.FillEllipse((Brush $Skin), $x-[int](34*$s),$y-[int](162*$s),$headW,$headH)
  $g.DrawEllipse((Pen $Black $lw), $x-[int](34*$s),$y-[int](162*$s),$headW,$headH)
  for ($i=0; $i -lt 5; $i++) {
    $g.DrawArc((Pen ([System.Drawing.Color]::FromArgb(55,25,10)) (3*$s)), $x-[int](42*$s)+$i*[int](12*$s),$y-[int](178*$s)+$i*3,[int](70*$s),[int](65*$s),205,80)
  }
  $g.FillRectangle((Brush $Violet), $x+[int](18*$s),$y-[int](166*$s),[int](18*$s),[int](7*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::White)), $x-[int](22*$s),$y-[int](136*$s),[int](18*$s),[int](22*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::White)), $x+[int](8*$s),$y-[int](136*$s),[int](18*$s),[int](22*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(80,42,18))), $x-[int](16*$s),$y-[int](129*$s),[int](8*$s),[int](10*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(80,42,18))), $x+[int](14*$s),$y-[int](129*$s),[int](8*$s),[int](10*$s))
  if ($pose -eq "surprised") {
    $g.DrawEllipse((Pen $Black (2*$s)), $x-[int](7*$s),$y-[int](110*$s),[int](14*$s),[int](12*$s))
  } elseif ($pose -eq "think") {
    $g.DrawArc((Pen $Black (3*$s)), $x-[int](12*$s),$y-[int](114*$s),[int](25*$s),[int](12*$s),10,160)
  } else {
    $g.FillPie((Brush ([System.Drawing.Color]::FromArgb(110,20,25))), $x-[int](18*$s),$y-[int](116*$s),[int](36*$s),[int](24*$s),0,180)
    $g.FillRectangle((Brush ([System.Drawing.Color]::White)), $x-[int](12*$s),$y-[int](112*$s),[int](24*$s),[int](5*$s))
  }
  $g.FillRectangle((Brush ([System.Drawing.Color]::White)), $x-[int](28*$s),$y-[int](88*$s),[int](56*$s),[int](42*$s))
  for ($yy=$y-[int](84*$s); $yy -lt $y-[int](48*$s); $yy += [int](12*$s)) { $g.DrawLine((Pen $Lilac (5*$s)), $x-[int](28*$s),$yy,$x+[int](28*$s),$yy) }
  $g.DrawRectangle((Pen $Black $lw), $x-[int](28*$s),$y-[int](88*$s),[int](56*$s),[int](42*$s))
  FillRound $g ([System.Drawing.RectangleF]::new($x-[int](25*$s),$y-[int](78*$s),[int](50*$s),[int](52*$s))) (6*$s) $Denim $Black $lw
  $g.DrawLine((Pen $Black (3*$s)), $x,$y-[int](78*$s),$x,$y-[int](26*$s))
  $g.DrawLine((Pen $Denim (8*$s)), $x-[int](20*$s),$y-[int](88*$s),$x-[int](9*$s),$y-[int](60*$s))
  $g.DrawLine((Pen $Denim (8*$s)), $x+[int](20*$s),$y-[int](88*$s),$x+[int](9*$s),$y-[int](60*$s))
  if ($pose -eq "jump" -or $pose -eq "excited") {
    $g.DrawLine((Pen $Skin (10*$s)), $x-[int](28*$s),$y-[int](82*$s),$x-[int](55*$s),$y-[int](132*$s))
    $g.DrawLine((Pen $Skin (10*$s)), $x+[int](28*$s),$y-[int](82*$s),$x+[int](55*$s),$y-[int](132*$s))
  } elseif ($pose -eq "surprised") {
    $g.DrawLine((Pen $Skin (10*$s)), $x-[int](28*$s),$y-[int](82*$s),$x-[int](34*$s),$y-[int](126*$s))
    $g.DrawLine((Pen $Skin (10*$s)), $x+[int](28*$s),$y-[int](82*$s),$x+[int](34*$s),$y-[int](126*$s))
  } else {
    $g.DrawLine((Pen $Skin (10*$s)), $x-[int](28*$s),$y-[int](82*$s),$x-[int](55*$s),$y-[int](55*$s))
    $g.DrawLine((Pen $Skin (10*$s)), $x+[int](28*$s),$y-[int](82*$s),$x+[int](55*$s),$y-[int](55*$s))
  }
  $g.DrawLine((Pen $Skin (11*$s)), $x-[int](13*$s),$y-[int](26*$s),$x-[int](18*$s),$y+[int](34*$s))
  $g.DrawLine((Pen $Skin (11*$s)), $x+[int](13*$s),$y-[int](26*$s),$x+[int](18*$s),$y+[int](34*$s))
  FillRound $g ([System.Drawing.RectangleF]::new($x-[int](36*$s),$y+[int](28*$s),[int](36*$s),[int](18*$s))) (8*$s) ([System.Drawing.Color]::White) $Black (2*$s)
  FillRound $g ([System.Drawing.RectangleF]::new($x+[int](2*$s),$y+[int](28*$s),[int](36*$s),[int](18*$s))) (8*$s) ([System.Drawing.Color]::White) $Black (2*$s)
}
function DrawClique($g,[int]$x,[int]$y,[float]$s,[string]$mood="teach") {
  $lw=[math]::Max(2,[int](4*$s))
  $g.DrawLine((Pen $Black (4*$s)), $x-[int](25*$s),$y-[int](58*$s),$x-[int](54*$s),$y-[int](82*$s))
  $g.DrawLine((Pen $Black (4*$s)), $x+[int](25*$s),$y-[int](58*$s),$x+[int](54*$s),$y-[int](82*$s))
  if ($mood -eq "excited") {
    $g.DrawLine((Pen $Black (4*$s)), $x-[int](25*$s),$y-[int](62*$s),$x-[int](55*$s),$y-[int](115*$s))
    $g.DrawLine((Pen $Black (4*$s)), $x+[int](25*$s),$y-[int](62*$s),$x+[int](55*$s),$y-[int](115*$s))
  }
  $body = [System.Drawing.RectangleF]::new($x-[int](46*$s),$y-[int](112*$s),[int](92*$s),[int](86*$s))
  FillRound $g $body (18*$s) $Sepia $Black $lw
  $g.FillRectangle((Brush $Leather), $x-[int](34*$s),$y-[int](104*$s),[int](68*$s),[int](18*$s))
  $g.DrawRectangle((Pen $Black (2*$s)), $x-[int](34*$s),$y-[int](104*$s),[int](68*$s),[int](18*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(185,230,255))), $x-[int](26*$s),$y-[int](88*$s),[int](52*$s),[int](52*$s))
  $g.DrawEllipse((Pen $Black $lw), $x-[int](26*$s),$y-[int](88*$s),[int](52*$s),[int](52*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(30,65,95))), $x-[int](12*$s),$y-[int](74*$s),[int](24*$s),[int](24*$s))
  if ($mood -eq "emotive") { $g.FillEllipse((Brush ([System.Drawing.Color]::White)), $x+[int](10*$s),$y-[int](80*$s),[int](8*$s),[int](8*$s)) }
  $g.DrawArc((Pen $Black (3*$s)), $x-[int](14*$s),$y-[int](50*$s),[int](28*$s),[int](16*$s),0,180)
  $g.DrawLine((Pen $Gold (7*$s)), $x-[int](35*$s),$y-[int](28*$s),$x+[int](35*$s),$y-[int](108*$s))
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(220,35,35))), $x+[int](42*$s),$y-[int](85*$s),[int](13*$s),[int](24*$s))
  if ($mood -eq "excited") { $g.DrawEllipse((Pen $Gold (4*$s)), $x+[int](36*$s),$y-[int](91*$s),[int](28*$s),[int](35*$s)) }
  $g.DrawLine((Pen $Black (4*$s)), $x,$y-[int](112*$s),$x,$y-[int](143*$s))
  $g.FillRectangle((Brush $Leather), $x-[int](15*$s),$y-[int](158*$s),[int](30*$s),[int](16*$s))
  $g.DrawRectangle((Pen $Black (2*$s)), $x-[int](15*$s),$y-[int](158*$s),[int](30*$s),[int](16*$s))
  $g.DrawLine((Pen $Black (4*$s)), $x-[int](18*$s),$y-[int](26*$s),$x-[int](25*$s),$y)
  $g.DrawLine((Pen $Black (4*$s)), $x+[int](18*$s),$y-[int](26*$s),$x+[int](25*$s),$y)
  $g.FillEllipse((Brush ([System.Drawing.Color]::White)), $x-[int](70*$s),$y-[int](121*$s),[int](22*$s),[int](20*$s))
  $g.FillEllipse((Brush ([System.Drawing.Color]::White)), $x+[int](48*$s),$y-[int](121*$s),[int](22*$s),[int](20*$s))
  DrawAlbum $g ($x-[int](24*$s)) ($y-[int](42*$s)) (0.35*$s) $true
}
function DrawLightBurst($g,[int]$x,[int]$y,[float]$s) {
  for ($i=0; $i -lt 18; $i++) {
    $a = $i * [math]::PI / 9
    $x2 = $x + [int]([math]::Cos($a)*90*$s)
    $y2 = $y + [int]([math]::Sin($a)*70*$s)
    $g.DrawLine((Pen $Gold (4*$s)), $x,$y,$x2,$y2)
  }
  $g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180,255,235,120))), $x-[int](60*$s),$y-[int](45*$s),[int](120*$s),[int](90*$s))
}
function DrawMemoryItems($g,[int]$x,[int]$y) {
  DrawPhoto $g $x $y 95 75 "family"
  $g.FillRectangle((Brush $Gold), $x+120,$y-5,80,95); $g.DrawRectangle((Pen $Black 3),$x+120,$y-5,80,95)
  $g.FillEllipse((Brush $Skin),$x+146,$y+18,28,32); $g.DrawEllipse((Pen $Black 2),$x+146,$y+18,28,32)
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(250,244,225))),$x+225,$y+8,95,70); $g.DrawRectangle((Pen $Black 2),$x+225,$y+8,95,70)
  for($i=0;$i -lt 5;$i++){ $g.DrawLine((Pen $Sepia 2),$x+238,$y+22+$i*10,$x+305,$y+22+$i*10) }
  $g.DrawLine((Pen $Violet 4),$x+225,$y+43,$x+320,$y+43)
}
function DrawLivingRoom($g,[int]$x,[int]$y,[int]$w,[int]$h) {
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(246,220,185))),$x,$y,$w,$h)
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(156,96,62))),$x,$y+$h-70,$w,70)
  $g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(255,226,145))),$x+$w-100,$y+40,50,50)
}
function DrawGrandma($g,[int]$x,[int]$y,[float]$s) {
  $g.FillEllipse((Brush ([System.Drawing.Color]::LightGray)),$x-[int](36*$s),$y-[int](148*$s),[int](72*$s),[int](62*$s))
  $g.FillEllipse((Brush $Skin),$x-[int](30*$s),$y-[int](135*$s),[int](60*$s),[int](62*$s))
  $g.DrawEllipse((Pen $Black (3*$s)),$x-[int](30*$s),$y-[int](135*$s),[int](60*$s),[int](62*$s))
  $g.DrawEllipse((Pen $Black (2*$s)),$x-[int](22*$s),$y-[int](113*$s),[int](17*$s),[int](14*$s))
  $g.DrawEllipse((Pen $Black (2*$s)),$x+[int](5*$s),$y-[int](113*$s),[int](17*$s),[int](14*$s))
  $g.DrawLine((Pen $Black (2*$s)),$x-[int](5*$s),$y-[int](106*$s),$x+[int](5*$s),$y-[int](106*$s))
  $g.DrawArc((Pen $Black (3*$s)),$x-[int](13*$s),$y-[int](94*$s),[int](26*$s),[int](16*$s),0,180)
  FillRound $g ([System.Drawing.RectangleF]::new($x-[int](45*$s),$y-[int](75*$s),[int](90*$s),[int](95*$s))) (18*$s) $LightViolet $Black (3*$s)
}
function MakeChars {
  $c=NewCanvas; $bmp=$c[0]; $g=$c[1]
  $g.Clear([System.Drawing.Color]::White)
  $frames = @(
    [pscustomobject]@{X=45;Y=45;W=215;H=315;Label="Curiosa";Kind="lis";Mood="think"},
    [pscustomobject]@{X=285;Y=45;W=215;H=315;Label="Animada";Kind="lis";Mood="jump"},
    [pscustomobject]@{X=525;Y=45;W=215;H=315;Label="Surpresa";Kind="lis";Mood="surprised"},
    [pscustomobject]@{X=765;Y=45;W=215;H=315;Label="Pensativa";Kind="lis";Mood="think"},
    [pscustomobject]@{X=80;Y=415;W=250;H=300;Label="Ensinando";Kind="clique";Mood="teach"},
    [pscustomobject]@{X=385;Y=415;W=250;H=300;Label="Animado";Kind="clique";Mood="excited"},
    [pscustomobject]@{X=690;Y=415;W=250;H=300;Label="Emotivo";Kind="clique";Mood="emotive"}
  )
  foreach($f in $frames) {
    FillRound $g ([System.Drawing.RectangleF]::new($f.X,$f.Y,$f.W,$f.H)) 28 ([System.Drawing.Color]::FromArgb(252,248,240)) $Black 4
    if($f.Kind -eq "lis") {
      DrawLis $g ($f.X + [int]($f.W/2)) ($f.Y + 205) 1.05 $f.Mood
      if($f.Label -eq "Curiosa") { DrawTrunk $g ($f.X + 28) ($f.Y + 205) .5 $true }
    } else {
      DrawClique $g ($f.X + [int]($f.W/2)) ($f.Y + 220) 1.35 $f.Mood
    }
    TextFit $g $f.Label ([System.Drawing.RectangleF]::new(($f.X + 5),($f.Y + $f.H - 52),($f.W - 10),42)) 28 16 "Bold"
  }
  FillRound $g ([System.Drawing.RectangleF]::new(95,775,835,670)) 30 ([System.Drawing.Color]::FromArgb(252,248,240)) $Black 5
  DrawLis $g 405 1210 1.9 "happy"
  DrawClique $g 640 1242 1.35 "teach"
  for($i=0;$i -lt 8;$i++){ $g.DrawLine((Pen $Gold 2),155,1385-$i*55,875,1385-$i*55) }
  TextFit $g "Comparação de Tamanho" ([System.Drawing.RectangleF]::new(145,1365,735,55)) 31 18 "Bold"
  SaveCanvas $bmp $g (Join-Path $OutDir "hq-albuns-fotografia-chars.png")
}
function MakePage1 {
  $c=NewCanvas; $bmp=$c[0]; $g=$c[1]
  $m=34; $pw=466; $ph=685; $gap=24
  Panel $g $m $m $pw $ph ([System.Drawing.Color]::FromArgb(228,198,156)); AtticBg $g $m $m $pw $ph
  DrawTrunk $g 245 520 1.05 $false
  $g.DrawLine((Pen $Leather 10),105,610,210,205); $g.DrawLine((Pen $Leather 10),155,610,260,205)
  for($i=0;$i -lt 7;$i++){ $g.DrawLine((Pen $Wood 6),120,565-$i*55,235,565-$i*55) }
  DrawLis $g 185 560 1.2 "think"
  Narrator $g (U "No s\u00f3t\u00e3o da casa da vov\u00f3...") 60 55 270 55
  Bubble $g (U "Que ba\u00fa empoeirado \u00e9 esse?") 125 125 310 82 245 430 24

  $x=$m+$pw+$gap; Panel $g $x $m $pw $ph ([System.Drawing.Color]::FromArgb(232,205,164)); AtticBg $g $x $m $pw $ph
  DrawTrunk $g ($x+55) 510 1.1 $true; DrawLis $g ($x+235) 575 1.35 "happy"; DrawAlbum $g ($x+275) 360 0.8 $false
  Bubble $g (U "Um \u00e1lbum de fotografia antigo!") ($x+72) 70 325 82 ($x+260) 380 24

  $y=$m+$ph+$gap; Panel $g $m $y $pw $ph ([System.Drawing.Color]::FromArgb(231,201,160)); AtticBg $g $m $y $pw $ph
  DrawLis $g 235 ($y+560) 1.25 "surprised"; DrawAlbum $g 170 ($y+430) 1.25 $true; DrawLightBurst $g 250 ($y+475) 1.2
  Bubble $g (U "Uau, o que est\u00e1 acontecendo?") 80 ($y+70) 345 82 230 ($y+388) 24

  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(235,208,166)); AtticBg $g $x $y $pw $ph
  DrawAlbum $g ($x+130) ($y+500) 1.15 $true; DrawLightBurst $g ($x+230) ($y+445) .9; DrawClique $g ($x+235) ($y+455) 1.15 "excited"; DrawLis $g ($x+345) ($y+590) 1.05 "surprised"
  Bubble $g (U "Clique! Eu sou o Clique!") ($x+35) ($y+65) 285 78 ($x+225) ($y+350) 23
  Bubble $g (U "Uma c\u00e2mera que fala?!") ($x+170) ($y+165) 260 76 ($x+335) ($y+395) 23
  SaveCanvas $bmp $g (Join-Path $OutDir "hq-albuns-fotografia-pg1.png")
}
function MakePage2 {
  $c=NewCanvas; $bmp=$c[0]; $g=$c[1]; $m=34; $pw=466; $ph=685; $gap=24
  $x=$m; $y=$m; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(234,207,167)); AtticBg $g $x $y $pw $ph
  DrawAlbum $g ($x+150) ($y+500) 1.1 $true; DrawLis $g ($x+120) ($y+555) 1.0 "think"; DrawClique $g ($x+315) ($y+535) 1.0 "teach"; DrawPhoto $g ($x+190) ($y+190) 185 130 "posed"
  $g.DrawLine((Pen $Gold 3),$x+315,$y+435,$x+280,$y+320); $g.DrawLine((Pen $Gold 3),$x+315,$y+435,$x+375,$y+320)
  Bubble $g (U "Essa foto foi combinada, posada!") ($x+20) ($y+45) 335 72 ($x+300) ($y+420) 21
  Bubble $g (U "Todos enfileirados, s\u00e9rios assim?") ($x+78) ($y+125) 355 72 ($x+130) ($y+380) 21
  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(236,210,170)); AtticBg $g $x $y $pw $ph
  DrawPhoto $g ($x+175) ($y+175) 200 140 "candid"; DrawClique $g ($x+325) ($y+535) 1.08 "excited"; DrawLis $g ($x+135) ($y+560) 1.05 "excited"
  Bubble $g (U "Essa foi de surpresa, de improviso!") ($x+25) ($y+45) 390 72 ($x+322) ($y+415) 20
  Bubble $g (U "Que engra\u00e7ado, parece um instante!") ($x+48) ($y+125) 365 72 ($x+145) ($y+385) 21
  $x=$m; $y=$m+$ph+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(239,217,181))
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(180,130,82))),$x,$y,$pw/2,$ph); $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(214,180,125))),$x+$pw/2,$y,$pw/2,$ph)
  for($i=0;$i -lt 4;$i++){ DrawTinyPerson $g ($x+70+$i*38) ($y+340) 1.0 $true; DrawTinyPerson $g ($x+280+$i*38) ($y+335-[int](($i%2)*30)) 1.0 $false }
  CardText $g (U "Posada") ($x+50) ($y+60) 130 48; CardText $g (U "De improviso") ($x+272) ($y+60) 160 48
  DrawLis $g ($x+150) ($y+625) .9 "happy"; DrawClique $g ($x+295) ($y+612) .8 "teach"
  Bubble $g (U "Uma \u00e9 armada, outra \u00e9 do momento!") ($x+35) ($y+430) 395 78 ($x+220) ($y+560) 21
  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(234,207,167)); AtticBg $g $x $y $pw $ph
  DrawLis $g ($x+205) ($y+555) 1.45 "happy"; DrawClique $g ($x+360) ($y+480) .95 "excited"
  Bubble $g (U "Estou posando, olha s\u00f3!") ($x+55) ($y+70) 285 72 ($x+205) ($y+350) 22
  Bubble $g (U "Clique! Ficou \u00f3tima, Lis!") ($x+150) ($y+155) 280 72 ($x+355) ($y+375) 22
  SaveCanvas $bmp $g (Join-Path $OutDir "hq-albuns-fotografia-pg2.png")
}
function MakePage3 {
  $c=NewCanvas; $bmp=$c[0]; $g=$c[1]; $m=34; $pw=466; $ph=685; $gap=24
  $x=$m; $y=$m; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(238,218,185)); DrawAlbum $g ($x+75) ($y+210) 2.1 $true; DrawPhoto $g ($x+210) ($y+270) 185 130 "family"; DrawLis $g ($x+115) ($y+610) .95 "think"; DrawClique $g ($x+380) ($y+565) .8 "teach"
  $g.DrawLine((Pen $Skin 8),$x+120,$y+455,$x+235,$y+335)
  Bubble $g "Por que estão tão arrumados assim?" ($x+25) ($y+50) 365 76 ($x+128) ($y+410) 21
  Bubble $g "É a roupa de domingo, Lis!" ($x+80) ($y+132) 320 72 ($x+365) ($y+440) 22
  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(213,171,112)); CardText $g "Roupa de domingo" ($x+120) ($y+45) 225 52
  $g.FillRectangle((Brush ([System.Drawing.Color]::FromArgb(185,130,77))),$x+0,$y+110,$pw,$ph-110)
  DrawTinyPerson $g ($x+110) ($y+390) 1.25 $true; $g.DrawLine((Pen ([System.Drawing.Color]::White) 5),$x+86,$y+285,$x+135,$y+285)
  DrawTinyPerson $g ($x+245) ($y+405) 1.25 $true; $g.FillEllipse((Brush $Black),$x+260,$y+415,45,18)
  DrawTinyPerson $g ($x+350) ($y+385) 1.15 $true; $g.DrawLine((Pen $Black 4),$x+330,$y+270,$x+370,$y+250)
  Bubble $g "A melhor roupa, para ocasiões especiais!" ($x+45) ($y+520) 375 76 ($x+250) ($y+405) 20
  $x=$m; $y=$m+$ph+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(235,207,165)); AtticBg $g $x $y $pw $ph
  DrawMemoryItems $g ($x+70) ($y+270); DrawLis $g ($x+170) ($y+610) 1.0 "think"; DrawClique $g ($x+350) ($y+575) .85 "teach"
  Bubble $g "Fotos, pinturas e músicas guardam memórias?" ($x+25) ($y+55) 400 78 ($x+165) ($y+390) 19
  Bubble $g "Sim! São fontes históricas da família!" ($x+55) ($y+142) 365 78 ($x+345) ($y+420) 20
  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(236,209,168)); AtticBg $g $x $y $pw $ph
  DrawPhoto $g ($x+145) ($y+250) 190 135 "family"; DrawLis $g ($x+205) ($y+620) 1.15 "think"; DrawClique $g ($x+365) ($y+570) .9 "teach"
  $g.DrawEllipse((Pen $Black 4),$x+245,$y+135,95,75); $g.DrawLine((Pen $Black 5),$x+315,$y+195,$x+350,$y+230); DrawPhoto $g ($x+270) ($y+152) 45 33 "family"
  Bubble $g "Essa fotografia conta uma história." ($x+35) ($y+45) 360 76 ($x+205) ($y+420) 21
  Bubble $g "Clique! Cada foto é um tesouro de memória!" ($x+25) ($y+535) 410 82 ($x+350) ($y+455) 18
  SaveCanvas $bmp $g (Join-Path $OutDir "hq-albuns-fotografia-pg3.png")
}
function MakePage4 {
  $c=NewCanvas; $bmp=$c[0]; $g=$c[1]; $m=34; $pw=466; $ph=685; $gap=24
  $x=$m; $y=$m; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(235,208,166)); AtticBg $g $x $y $pw $ph
  DrawTrunk $g ($x+285) ($y+460) .9 $false; DrawClique $g ($x+355) ($y+452) .75 "emotive"; DrawLis $g ($x+180) ($y+585) 1.2 "think"; DrawAlbum $g ($x+155) ($y+395) .95 $false
  DrawPhoto $g ($x+55) ($y+270) 56 42 "posed"; DrawPhoto $g ($x+125) ($y+270) 56 42 "candid"; $g.FillRectangle((Brush $Gold),$x+200,$y+265,60,50); $g.DrawRectangle((Pen $Black 2),$x+200,$y+265,60,50)
  Bubble $g "Aprendi tanto sobre fotos antigas!" ($x+35) ($y+55) 365 74 ($x+180) ($y+405) 21
  Bubble $g "Álbuns guardam nossa história, Lis!" ($x+42) ($y+140) 360 74 ($x+345) ($y+350) 20
  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(235,208,166)); AtticBg $g $x $y $pw $ph
  DrawLis $g ($x+190) ($y+580) 1.25 "happy"; DrawAlbum $g ($x+205) ($y+365) .65 $false; DrawClique $g ($x+345) ($y+500) .9 "excited"
  $g.DrawLine((Pen $Leather 10),$x+55,$y+630,$x+190,$y+205); $g.DrawLine((Pen $Leather 10),$x+105,$y+630,$x+240,$y+205)
  Bubble $g "Vamos guardar isso com carinho!" ($x+30) ($y+58) 340 74 ($x+340) ($y+385) 21
  Bubble $g "Vou mostrar pra vovó agora mesmo!" ($x+55) ($y+145) 360 74 ($x+195) ($y+370) 20
  $x=$m; $y=$m+$ph+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(246,220,185)); DrawLivingRoom $g $x $y $pw $ph
  DrawGrandma $g ($x+350) ($y+545) 1.2; DrawLis $g ($x+165) ($y+600) 1.05 "happy"; DrawAlbum $g ($x+235) ($y+390) .75 $false; DrawClique $g ($x+95) ($y+525) .52 "excited"
  Bubble $g "Olha o que encontramos, vovó!" ($x+38) ($y+62) 335 74 ($x+168) ($y+390) 21
  Bubble $g "Clique! Que reencontro emocionante!" ($x+45) ($y+145) 380 74 ($x+95) ($y+430) 20
  $x=$m+$pw+$gap; Panel $g $x $y $pw $ph ([System.Drawing.Color]::FromArgb(238,218,185))
  FillRound $g ([System.Drawing.RectangleF]::new($x+55,$y+78,355,455)) 38 ([System.Drawing.Color]::FromArgb(223,185,255)) $Violet 10
  for($i=0;$i -lt 8;$i++){ DrawPhoto $g ($x+70+($i%4)*82) ($y+92+[math]::Floor($i/4)*380) 44 34 "posed" }
  DrawLis $g ($x+170) ($y+540) 1.18 "excited"; DrawClique $g ($x+330) ($y+500) 1.0 "excited"
  Bubble $g "Vem brincar com a gente no portal!" ($x+30) ($y+45) 390 74 ($x+175) ($y+345) 20
  Bubble $g "Clique! Tem atividades incríveis te esperando!" ($x+20) ($y+540) 420 76 ($x+325) ($y+430) 18
  CardText $g "Continue explorando!" ($x+100) ($y+620) 270 46
  SaveCanvas $bmp $g (Join-Path $OutDir "hq-albuns-fotografia-pg4.png")
}

MakeChars
MakePage1
MakePage2
MakePage3
MakePage4

Get-ChildItem $OutDir -Filter "hq-albuns-fotografia-*.png" |
  Sort-Object Name |
  ForEach-Object {
    $img=[System.Drawing.Image]::FromFile($_.FullName)
    try { "{0} | {1}x{2}" -f $_.FullName,$img.Width,$img.Height }
    finally { $img.Dispose() }
  }
