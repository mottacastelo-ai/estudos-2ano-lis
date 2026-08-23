Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$ErrorActionPreference = "Stop"

$OutDir = "C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\portugues\sons-letras-j-g-til-s"
$W = 1024
$H = 1536
$Gutter = 18
$PanelW = [int](($W - $Gutter * 3) / 2)
$PanelH = [int](($H - $Gutter * 3) / 2)

$C = @{
  Brown=[System.Drawing.ColorTranslator]::FromHtml("#2b140b")
  Burnt=[System.Drawing.ColorTranslator]::FromHtml("#7A1F04")
  Orange=[System.Drawing.ColorTranslator]::FromHtml("#E8430A")
  Coral=[System.Drawing.ColorTranslator]::FromHtml("#FB8C5A")
  Peach=[System.Drawing.ColorTranslator]::FromHtml("#FFD2B8")
  Cream=[System.Drawing.ColorTranslator]::FromHtml("#FFF4EF")
  Sand=[System.Drawing.ColorTranslator]::FromHtml("#F7E9C9")
  Grey=[System.Drawing.ColorTranslator]::FromHtml("#D6D1C8")
  Green=[System.Drawing.ColorTranslator]::FromHtml("#78B96A")
  Blue=[System.Drawing.ColorTranslator]::FromHtml("#62B8E8")
}

function Font-Bold([float]$size) { New-Object System.Drawing.Font("Arial", $size, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel) }
function Brush($color) { New-Object System.Drawing.SolidBrush($color) }
function PenX($color, [float]$w=3) { New-Object System.Drawing.Pen($color, $w) }
function Rect([int]$x,[int]$y,[int]$w,[int]$h) { New-Object System.Drawing.Rectangle $x,$y,$w,$h }

function RoundedPath($x,$y,$w,$h,$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x,$y,$d,$d,180,90); $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
  $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $p.AddArc($x,$y+$h-$d,$d,$d,90,90)
  $p.CloseFigure(); $p
}
function FillRound($g,$x,$y,$w,$h,$r,$fill,$outline=[System.Drawing.Color]::Black,$lw=3) {
  $path = RoundedPath $x $y $w $h $r
  $g.FillPath((Brush $fill), $path); $g.DrawPath((PenX $outline $lw), $path)
}
function DrawTextCenter($g,$text,$font,$rect,$color=$C.Brown) {
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $sf.Trimming = [System.Drawing.StringTrimming]::None
  $rf = [System.Drawing.RectangleF]::new($rect.X, $rect.Y, $rect.Width, $rect.Height)
  $g.DrawString($text,$font,(Brush $color),$rf,$sf)
}
function Bubble($g,$x,$y,$w,$h,$text,$size=24) {
  FillRound $g $x $y $w $h 24 ([System.Drawing.Color]::White) ([System.Drawing.Color]::Black) 4
  DrawTextCenter $g $text (Font-Bold $size) (Rect ($x+8) ($y+6) ($w-16) ($h-12))
}
function Caption($g,$x,$y,$w,$h,$text) {
  FillRound $g $x $y $w $h 10 $C.Cream $C.Orange 4
  DrawTextCenter $g $text (Font-Bold 22) (Rect ($x+5) ($y+4) ($w-10) ($h-8))
}
function Tile($g,$x,$y,$w,$h,$text,$hiStart=-1,$hiLen=0,$size=34,$fill=$C.Sand) {
  FillRound $g $x $y $w $h 15 $fill ([System.Drawing.Color]::Black) 4
  $font = Font-Bold $size
  $fmt = [System.Drawing.StringFormat]::GenericTypographic
  $total = $g.MeasureString($text,$font,1000,$fmt).Width
  $xx = $x + ($w - $total) / 2
  $yy = $y + ($h - $size) / 2 - 2
  for($i=0;$i -lt $text.Length;$i++){
    $ch = $text.Substring($i,1)
    $hot = ($hiStart -ge 0 -and $i -ge $hiStart -and $i -lt ($hiStart+$hiLen))
    $drawColor = $C.Brown
    if($hot){ $drawColor = $C.Orange }
    $g.DrawString($ch,$font,(Brush $drawColor),$xx,$yy,$fmt)
    $xx += $g.MeasureString($ch,$font,1000,$fmt).Width
  }
}
function TileHiRanges($g,$x,$y,$w,$h,$text,$ranges,$size=34,$fill=$C.Sand) {
  FillRound $g $x $y $w $h 15 $fill ([System.Drawing.Color]::Black) 4
  $font = Font-Bold $size; $fmt = [System.Drawing.StringFormat]::GenericTypographic
  $total = $g.MeasureString($text,$font,1000,$fmt).Width
  $xx = $x + ($w - $total) / 2; $yy = $y + ($h - $size) / 2 - 2
  for($i=0;$i -lt $text.Length;$i++){
    $hot=$false; foreach($r in $ranges){ if($i -ge $r[0] -and $i -lt $r[1]){$hot=$true} }
    $ch=$text.Substring($i,1)
    $drawColor = $C.Brown
    if($hot){ $drawColor = $C.Orange }
    $g.DrawString($ch,$font,(Brush $drawColor),$xx,$yy,$fmt)
    $xx += $g.MeasureString($ch,$font,1000,$fmt).Width
  }
}
function Origin {
  param([int]$idx)
  $col = $idx % 2; $row = [math]::Floor($idx / 2)
  @([int]($Gutter + $col * ($PanelW + $Gutter)), [int]($Gutter + $row * ($PanelH + $Gutter)))
}
function NewPage() {
  $bmp = [System.Drawing.Bitmap]::new([int]$W,[int]$H)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear([System.Drawing.Color]::White)
  for($i=0;$i -lt 4;$i++){ $o=Origin $i; $g.FillRectangle((Brush $C.Cream),(Rect $o[0] $o[1] $PanelW $PanelH)); $g.DrawRectangle((PenX ([System.Drawing.Color]::Black) 6),(Rect $o[0] $o[1] $PanelW $PanelH)) }
  @($bmp,$g)
}
function ReadingRoom($g,$ox,$oy){
  $g.FillRectangle((Brush $C.Blue),(Rect ($ox+35) ($oy+45) 110 120)); $g.DrawRectangle((PenX ([System.Drawing.Color]::Black) 3),(Rect ($ox+35) ($oy+45) 110 120))
  $g.FillRectangle((Brush $C.Coral),(Rect ($ox+18) ($oy+38) 18 136)); $g.FillRectangle((Brush $C.Coral),(Rect ($ox+145) ($oy+38) 18 136))
  $g.FillEllipse((Brush ([System.Drawing.ColorTranslator]::FromHtml("#D8A86B"))),(Rect ($ox+105) ($oy+520) 255 140)); $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) 3),(Rect ($ox+105) ($oy+520) 255 140))
  $g.FillRectangle((Brush ([System.Drawing.ColorTranslator]::FromHtml("#9E5B28"))),(Rect ($ox+360) ($oy+70) 100 250)); $g.DrawRectangle((PenX ([System.Drawing.Color]::Black) 3),(Rect ($ox+360) ($oy+70) 100 250))
  $colors=@($C.Blue,$C.Orange,$C.Green,[System.Drawing.Color]::Gold,[System.Drawing.Color]::MediumPurple)
  for($r=0;$r -lt 3;$r++){ for($i=0;$i -lt 5;$i++){ $g.FillRectangle((Brush $colors[($i+$r)%5]),(Rect ($ox+368+$i*17) ($oy+82+$r*75) 12 52)); $g.DrawRectangle((PenX ([System.Drawing.Color]::Black) 1),(Rect ($ox+368+$i*17) ($oy+82+$r*75) 12 52)) } }
  $g.FillEllipse((Brush $C.Green),(Rect ($ox+25) ($oy+340) 100 170)); $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) 2),(Rect ($ox+25) ($oy+340) 100 170))
  $g.FillRectangle((Brush ([System.Drawing.ColorTranslator]::FromHtml("#A76533"))),(Rect ($ox+55) ($oy+505) 45 55)); $g.DrawRectangle((PenX ([System.Drawing.Color]::Black) 2),(Rect ($ox+55) ($oy+505) 45 55))
}
function Lis($g,$cx,$cy,$s=1,$pose="happy"){
  $skin=[System.Drawing.ColorTranslator]::FromHtml("#F5B38D"); $hair=[System.Drawing.ColorTranslator]::FromHtml("#6B2D10")
  $g.FillEllipse((Brush $hair),(Rect ($cx-58*$s) ($cy-145*$s) (116*$s) (125*$s))); $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) (3*$s)),(Rect ($cx-58*$s) ($cy-145*$s) (116*$s) (125*$s)))
  for($i=0;$i -lt 2;$i++){ FillRound $g ($cx-55*$s) ($cy+(-102+13*$i)*$s) (32*$s) (9*$s) 4 $C.Orange $C.Burnt 1 }
  $g.FillEllipse((Brush $skin),(Rect ($cx-39*$s) ($cy-122*$s) (78*$s) (82*$s))); $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) (3*$s)),(Rect ($cx-39*$s) ($cy-122*$s) (78*$s) (82*$s)))
  foreach($ex in @(-25,10)){ $g.FillEllipse((Brush ([System.Drawing.Color]::White)),(Rect ($cx+$ex*$s) ($cy-93*$s) (20*$s) (24*$s))); $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) 2),(Rect ($cx+$ex*$s) ($cy-93*$s) (20*$s) (24*$s))); $g.FillEllipse((Brush ([System.Drawing.ColorTranslator]::FromHtml("#5A260E"))),(Rect ($cx+($ex+7)*$s) ($cy-87*$s) (10*$s) (13*$s))) }
  if($pose -eq "surprise"){ $g.FillEllipse((Brush ([System.Drawing.ColorTranslator]::FromHtml("#5A1208"))),(Rect ($cx-9*$s) ($cy-66*$s) (18*$s) (20*$s))) } else { $g.DrawArc((PenX ([System.Drawing.ColorTranslator]::FromHtml("#5A1208")) (4*$s)),($cx-22*$s),($cy-70*$s),(46*$s),(31*$s),0,180) }
  FillRound $g ($cx-33*$s) ($cy-42*$s) (66*$s) (86*$s) 12 $C.Orange ([System.Drawing.Color]::Black) (3*$s)
  $g.FillRectangle((Brush ([System.Drawing.ColorTranslator]::FromHtml("#FFF9ED"))),(Rect ($cx-28*$s) ($cy-42*$s) (56*$s) (38*$s))); $g.DrawString("~",(Font-Bold (30*$s)),(Brush $C.Orange),($cx-8*$s),($cy-42*$s))
  $g.FillPolygon((Brush ([System.Drawing.ColorTranslator]::FromHtml("#FFF2D7"))),@([System.Drawing.PointF]::new($cx+38*$s,$cy-25*$s),[System.Drawing.PointF]::new($cx+75*$s,$cy+16*$s),[System.Drawing.PointF]::new($cx+58*$s,$cy+70*$s),[System.Drawing.PointF]::new($cx+24*$s,$cy+35*$s))); $g.DrawString("A",(Font-Bold (28*$s)),(Brush $C.Orange),($cx+45*$s),($cy+16*$s))
  if($pose -eq "jump"){ $arms=@(@(-32,-20,-78,-83),@(32,-20,75,-84)) } elseif($pose -eq "point"){ $arms=@(@(-32,-18,-62,15),@(32,-18,93,-50)) } else { $arms=@(@(-32,-18,-62,5),@(32,-18,62,5)) }
  foreach($a in $arms){ $g.DrawLine((PenX $skin (8*$s)),($cx+$a[0]*$s),($cy+$a[1]*$s),($cx+$a[2]*$s),($cy+$a[3]*$s)) }
  foreach($lx in @(-16,16)){ $g.FillRectangle((Brush $C.Orange),(Rect ($cx+$lx*$s-8*$s) ($cy+40*$s) (16*$s) (38*$s))); $g.FillRectangle((Brush $C.Coral),(Rect ($cx+$lx*$s-8*$s) ($cy+76*$s) (16*$s) (35*$s))); FillRound $g ($cx+$lx*$s-18*$s) ($cy+108*$s) (42*$s) (16*$s) 8 ([System.Drawing.Color]::White) ([System.Drawing.Color]::Black) 2 }
}
function Tilim($g,$cx,$cy,$s=1,$kind="wave"){
  $pen=PenX $C.Orange (36*$s); $pen.StartCap="Round"; $pen.EndCap="Round"; $pen.LineJoin="Round"
  if($kind -eq "s"){ $pts=@([System.Drawing.PointF]::new($cx+20*$s,$cy-70*$s),[System.Drawing.PointF]::new($cx-45*$s,$cy-65*$s),[System.Drawing.PointF]::new($cx-55*$s,$cy-15*$s),[System.Drawing.PointF]::new($cx+25*$s,$cy-5*$s),[System.Drawing.PointF]::new($cx+50*$s,$cy+40*$s),[System.Drawing.PointF]::new($cx-30*$s,$cy+70*$s)) }
  elseif($kind -eq "j"){ $pts=@([System.Drawing.PointF]::new($cx+22*$s,$cy-70*$s),[System.Drawing.PointF]::new($cx+10*$s,$cy-20*$s),[System.Drawing.PointF]::new($cx+8*$s,$cy+45*$s),[System.Drawing.PointF]::new($cx-36*$s,$cy+62*$s),[System.Drawing.PointF]::new($cx-52*$s,$cy+25*$s)) }
  elseif($kind -eq "g"){ $pts=@([System.Drawing.PointF]::new($cx+45*$s,$cy-40*$s),[System.Drawing.PointF]::new($cx-40*$s,$cy-50*$s),[System.Drawing.PointF]::new($cx-58*$s,$cy+18*$s),[System.Drawing.PointF]::new($cx+18*$s,$cy+48*$s),[System.Drawing.PointF]::new($cx+55*$s,$cy+6*$s),[System.Drawing.PointF]::new($cx+12*$s,$cy-2*$s)) }
  else { $pts=@([System.Drawing.PointF]::new($cx-62*$s,$cy+18*$s),[System.Drawing.PointF]::new($cx-30*$s,$cy-34*$s),[System.Drawing.PointF]::new($cx+8*$s,$cy+30*$s),[System.Drawing.PointF]::new($cx+58*$s,$cy-18*$s)) }
  $g.DrawCurve($pen,$pts)
  $g.FillEllipse((Brush ([System.Drawing.Color]::White)),(Rect ($cx-29*$s) ($cy-33*$s) (21*$s) (29*$s))); $g.FillEllipse((Brush ([System.Drawing.Color]::White)),(Rect ($cx+7*$s) ($cy-35*$s) (22*$s) (30*$s)))
  $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) 2),(Rect ($cx-29*$s) ($cy-33*$s) (21*$s) (29*$s))); $g.DrawEllipse((PenX ([System.Drawing.Color]::Black) 2),(Rect ($cx+7*$s) ($cy-35*$s) (22*$s) (30*$s)))
  $g.FillEllipse((Brush $C.Brown),(Rect ($cx-20*$s) ($cy-24*$s) (10*$s) (14*$s))); $g.FillEllipse((Brush $C.Brown),(Rect ($cx+15*$s) ($cy-25*$s) (10*$s) (14*$s)))
  $g.FillEllipse((Brush $C.Peach),(Rect ($cx-12*$s) ($cy-48*$s) (26*$s) (27*$s))); $g.DrawEllipse((PenX $C.Burnt 2),(Rect ($cx-12*$s) ($cy-48*$s) (26*$s) (27*$s)))
  $g.DrawArc((PenX $C.Burnt (5*$s)),($cx-35*$s),($cy-1*$s),(73*$s),(44*$s),0,180)
  $g.DrawLine((PenX $C.Orange (5*$s)),($cx-58*$s),($cy+6*$s),($cx-85*$s),($cy-15*$s)); $g.DrawLine((PenX $C.Orange (5*$s)),($cx+58*$s),($cy+2*$s),($cx+85*$s),($cy-18*$s))
  $g.DrawArc((PenX ([System.Drawing.ColorTranslator]::FromHtml("#FFF2D7")) (12*$s)),($cx-54*$s),($cy-67*$s),(57*$s),(37*$s),190,160)
  for($i=0;$i -lt 5;$i++){ $g.FillEllipse((Brush ([System.Drawing.Color]::Gold)),(Rect ($cx+(55+$i*17)*$s) ($cy+(-50+$i*12)*$s) (13*$s) (13*$s))) }
}
function IconText($g,$x,$y,$text,$size=30,$color=$C.Brown){ $g.DrawString($text,(Font-Bold $size),(Brush $color),$x,$y) }
function SavePage($bmp,$g,$path){ $g.Dispose(); $bmp.Save($path,[System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose(); Write-Output "saved $path" }

# Page 1
$pg=NewPage; $bmp=$pg[0]; $g=$pg[1]
$o=Origin 0; ReadingRoom $g $o[0] $o[1]; Lis $g ($o[0]+230) ($o[1]+455) .95 "surprise"; FillRound $g ($o[0]+132) ($o[1]+215) 245 290 18 $C.Blue ([System.Drawing.Color]::Black) 4; DrawTextCenter $g "João e o`nFeijoeiro Mágico" (Font-Bold 30) (Rect ($o[0]+142) ($o[1]+230) 225 95) ([System.Drawing.Color]::White); Bubble $g ($o[0]+28) ($o[1]+38) 290 72 "João e o Feijoeiro Mágico!"
$o=Origin 1; ReadingRoom $g $o[0] $o[1]; FillRound $g ($o[0]+28) ($o[1]+190) 250 300 18 $C.Blue ([System.Drawing.Color]::Black) 4; Tile $g ($o[0]+64) ($o[1]+234) 175 78 "João" 0 1 48 ([System.Drawing.Color]::White); Tilim $g ($o[0]+172) ($o[1]+210) .72; Lis $g ($o[0]+360) ($o[1]+500) .82 "surprise"; Bubble $g ($o[0]+205) ($o[1]+52) 255 96 "Oi! Eu moro em cima do ão!"; Bubble $g ($o[0]+242) ($o[1]+158) 210 100 "Você mora dentro do livro?"
$o=Origin 2; Caption $g ($o[0]+22) ($o[1]+24) 285 54 "O som do j é sempre o mesmo."; @("ja","je","ji","jo","ju") | ForEach-Object -Begin {$i=0} -Process { Tile $g ($o[0]+32+$i*86) ($o[1]+130) 72 52 $_ 0 $_.Length 34 $C.Sand; $i++ }; Tilim $g ($o[0]+190) ($o[1]+365) .75 "j"; Lis $g ($o[0]+390) ($o[1]+535) .72 "think"; Bubble $g ($o[0]+66) ($o[1]+455) 285 86 "Ja, je, ji, jo, ju — mesmo som!"; Bubble $g ($o[0]+210) ($o[1]+585) 250 78 "Com toda vogal ele não muda?"
$o=Origin 3; $entries=@(@("jipe","jipe"),@("loja","loja"),@("vejo","vejo"),@("julho","julho"),@("jegue","jegue")); $coords=@(@(36,118),@(204,74),@(360,130),@(110,304),@(290,315)); for($i=0;$i -lt 5;$i++){ IconText $g ($o[0]+$coords[$i][0]+35) ($o[1]+$coords[$i][1]-60) $entries[$i][1] 20 $C.Brown; $w=$entries[$i][0]; Tile $g ($o[0]+$coords[$i][0]) ($o[1]+$coords[$i][1]) 140 60 $w $w.IndexOf("j") 1 25 ([System.Drawing.Color]::White) }; Lis $g ($o[0]+155) ($o[1]+595) .72 "jump"; Tilim $g ($o[0]+358) ($o[1]+560) .62; Bubble $g ($o[0]+18) ($o[1]+430) 285 78 "Jipe, loja, vejo, julho, jegue!"; Bubble $g ($o[0]+258) ($o[1]+470) 210 84 "Isso! O j nunca me engana!"
SavePage $bmp $g (Join-Path $OutDir "hq-sons-letras-j-g-til-s-pg1.png")

# Page 2
$pg=NewPage; $bmp=$pg[0]; $g=$pg[1]
$o=Origin 0; $g.FillRectangle((Brush ([System.Drawing.ColorTranslator]::FromHtml("#F6D8B8"))),(Rect ($o[0]+4) ($o[1]+240) ($PanelW-8) 490)); Tile $g ($o[0]+144) ($o[1]+170) 210 74 "gelo" 0 1 48 ([System.Drawing.ColorTranslator]::FromHtml("#E9FAFF")); Lis $g ($o[0]+126) ($o[1]+590) .75 "surprise"; Tilim $g ($o[0]+388) ($o[1]+410) .6; Bubble $g ($o[0]+165) ($o[1]+36) 292 74 "Escuta o g dessa palavra aqui!"; Bubble $g ($o[0]+32) ($o[1]+75) 235 70 "Parece o som do j!"
$o=Origin 1; Caption $g ($o[0]+16) ($o[1]+20) 180 48 "Antes de e ou i,"; Tile $g ($o[0]+175) ($o[1]+68) 150 50 "g + e / i" 0 1 22 $C.Sand; $ws=@("gelo","gente","girassol","página"); $cs=@(@(88,170),@(275,170),@(88,306),@(275,306)); for($i=0;$i -lt 4;$i++){ Tile $g ($o[0]+$cs[$i][0]) ($o[1]+$cs[$i][1]) 160 58 $ws[$i] 0 1 25 ([System.Drawing.Color]::White) }; Caption $g ($o[0]+230) ($o[1]+470) 240 58 "o g tem som igual ao do j."; Tilim $g ($o[0]+230) ($o[1]+505) .64 "g"; Lis $g ($o[0]+398) ($o[1]+625) .58 "happy"; Bubble $g ($o[0]+54) ($o[1]+560) 300 72 "Gelo, gente, girassol, página!"
$o=Origin 2; $g.FillRectangle((Brush $C.Sand),(Rect ($o[0]+4) ($o[1]+4) ($PanelW-8) ($PanelH-8))); Tile $g ($o[0]+172) ($o[1]+58) 180 52 "g + a / o / u" 0 1 22 $C.Sand; Caption $g ($o[0]+265) ($o[1]+125) 200 48 "Antes de a, o e u,"; Caption $g ($o[0]+26) ($o[1]+548) 230 52 "o g tem som diferente."; $ws=@("galo","gorila","guloso","mago"); for($i=0;$i -lt 4;$i++){ Tile $g ($o[0]+24+$i*112) ($o[1]+285) 102 56 $ws[$i] 0 1 21 ([System.Drawing.Color]::White) }; Tilim $g ($o[0]+118) ($o[1]+470) .7; Lis $g ($o[0]+376) ($o[1]+570) .65 "happy"; Bubble $g ($o[0]+250) ($o[1]+405) 220 72 "Aqui o g mudou de voz!"; Bubble $g ($o[0]+24) ($o[1]+420) 210 82 "O g é fofoqueiro mesmo!"
$o=Origin 3; $g.DrawLine((PenX $C.Orange 4),($o[0]+$PanelW/2),($o[1]+20),($o[0]+$PanelW/2),($o[1]+$PanelH-20)); Tile $g ($o[0]+35) ($o[1]+200) 200 70 "feijoeiro" 3 1 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+285) ($o[1]+200) 175 70 "mágico" 2 1 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+196) ($o[1]+278) 140 48 "mesmo som" -1 0 21 ([System.Drawing.ColorTranslator]::FromHtml("#FFE5EF")); Lis $g ($o[0]+250) ($o[1]+600) .7 "jump"; Tilim $g ($o[0]+255) ($o[1]+415) .58; Bubble $g ($o[0]+22) ($o[1]+420) 270 84 "Feijoeiro e mágico têm o mesmo som!"; Bubble $g ($o[0]+260) ($o[1]+455) 205 82 "Acertou! O g virou j aqui!"
SavePage $bmp $g (Join-Path $OutDir "hq-sons-letras-j-g-til-s-pg2.png")

# Page 3
$pg=NewPage; $bmp=$pg[0]; $g=$pg[1]
$o=Origin 0; for($i=0;$i -lt 3;$i++){ $g.FillRectangle((Brush ([System.Drawing.ColorTranslator]::FromHtml("#A76B34"))),(Rect ($o[0]+40) ($o[1]+210+$i*78) 400 50)) }; Tile $g ($o[0]+145) ($o[1]+145) 190 72 "pao" -1 0 48 $C.Grey; IconText $g ($o[0]+170) ($o[1]+80) "? ? ?" 44 ([System.Drawing.Color]::Gray); Lis $g ($o[0]+92) ($o[1]+650) .62 "think"; Tilim $g ($o[0]+380) ($o[1]+265) .58; Bubble $g ($o[0]+24) ($o[1]+34) 250 68 "Essa palavra está estranha!"; Bubble $g ($o[0]+225) ($o[1]+345) 235 86 "A palavra tá pelada! Segura aí!"
$o=Origin 1; Caption $g ($o[0]+22) ($o[1]+24) 250 50 "O til marca o som nasal."; Tile $g ($o[0]+154) ($o[1]+178) 190 84 "pão" 0 2 48 ([System.Drawing.Color]::White); Tilim $g ($o[0]+236) ($o[1]+146) .38; $g.FillEllipse((Brush ([System.Drawing.ColorTranslator]::FromHtml("#D99B3B"))),(Rect ($o[0]+180) ($o[1]+340) 150 70)); Lis $g ($o[0]+394) ($o[1]+615) .58 "surprise"; Bubble $g ($o[0]+48) ($o[1]+425) 305 84 "Ãããã! Isso aí é pra cantar no nariz!"; Bubble $g ($o[0]+260) ($o[1]+530) 200 72 "Virou pão de verdade!"
$o=Origin 2; Tile $g ($o[0]+42) ($o[1]+130) 116 56 "mao" -1 0 25 $C.Grey; Tile $g ($o[0]+268) ($o[1]+130) 122 56 "mão" 1 1 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+42) ($o[1]+275) 116 56 "maca" -1 0 25 $C.Grey; TileHiRanges $g ($o[0]+268) ($o[1]+275) 132 56 "maçã" @(@(2,4)) 25 ([System.Drawing.Color]::White); IconText $g ($o[0]+405) ($o[1]+118) "mão" 22 $C.Brown; IconText $g ($o[0]+405) ($o[1]+260) "maçã" 22 $C.Brown; Tilim $g ($o[0]+230) ($o[1]+420) .56; Lis $g ($o[0]+410) ($o[1]+650) .58 "happy"; Bubble $g ($o[0]+24) ($o[1]+515) 270 82 "Ponho o chapeuzinho e a palavra muda!"; Bubble $g ($o[0]+250) ($o[1]+510) 220 78 "Mão e maçã! Que mágica boa!"
$o=Origin 3; $fam=@(@("ão",50,82),@("ãe",270,82),@("õe",50,362),@("ã",270,362)); foreach($f in $fam){ Tile $g ($o[0]+$f[1]) ($o[1]+$f[2]) 145 66 $f[0] 0 $f[0].Length 48 $C.Sand }; $words=@("avião","coração","limão","feijão"); for($i=0;$i -lt 4;$i++){ Tile $g ($o[0]+62) ($o[1]+156+$i*48) 150 40 $words[$i] ($words[$i].Length-2) 2 21 ([System.Drawing.Color]::White) }; $words=@("romã","irmã"); for($i=0;$i -lt 2;$i++){ Tile $g ($o[0]+286) ($o[1]+442+$i*50) 130 40 $words[$i] ($words[$i].Length-1) 1 21 ([System.Drawing.Color]::White) }; Lis $g ($o[0]+82) ($o[1]+662) .57 "jump"; Tilim $g ($o[0]+402) ($o[1]+125) .55; Bubble $g ($o[0]+22) ($o[1]+565) 150 60 "Sem til, é 'pao'." 20; Bubble $g ($o[0]+164) ($o[1]+555) 210 74 "Com til, é PÃO! Tcharam!" 20; Bubble $g ($o[0]+212) ($o[1]+635) 250 60 "Agora eu canto tudo no nariz!" 20
SavePage $bmp $g (Join-Path $OutDir "hq-sons-letras-j-g-til-s-pg3.png")

# Page 4
$pg=NewPage; $bmp=$pg[0]; $g=$pg[1]
$o=Origin 0; @("sa","se","si","so","su") | ForEach-Object -Begin {$i=0} -Process { Tile $g ($o[0]+32+$i*86) ($o[1]+38) 72 52 $_ 0 $_.Length 34 $C.Sand; $i++ }; Tilim $g ($o[0]+228) ($o[1]+345) 1.05 "s"; Lis $g ($o[0]+392) ($o[1]+592) .67 "surprise"; Bubble $g ($o[0]+45) ($o[1]+505) 210 70 "Olha! Virei a letra s!"; Bubble $g ($o[0]+260) ($o[1]+500) 190 66 "Sa, se, si, so, su!"
$o=Origin 1; Caption $g ($o[0]+20) ($o[1]+28) 245 50 "O s no início da sílaba."; Tile $g ($o[0]+30) ($o[1]+150) 132 58 "sa-la-da" 0 2 21 ([System.Drawing.Color]::White); Tile $g ($o[0]+185) ($o[1]+150) 132 58 "su-co" 0 2 21 ([System.Drawing.Color]::White); Tile $g ($o[0]+335) ($o[1]+150) 132 58 "sa-pa-to" 0 2 21 ([System.Drawing.Color]::White); IconText $g ($o[0]+60) ($o[1]+305) "salada" 22 $C.Green; IconText $g ($o[0]+210) ($o[1]+305) "suco" 22 $C.Orange; IconText $g ($o[0]+360) ($o[1]+305) "sapato" 22 $C.Brown; Tilim $g ($o[0]+255) ($o[1]+302) .55; Lis $g ($o[0]+416) ($o[1]+642) .58 "happy"; Bubble $g ($o[0]+24) ($o[1]+520) 226 72 "Aqui o s começa a sílaba."; Bubble $g ($o[0]+192) ($o[1]+595) 270 66 "Sa-la-da, su-co, sa-pa-to!"
$o=Origin 2; $g.FillRectangle((Brush ([System.Drawing.ColorTranslator]::FromHtml("#FFE7C5"))),(Rect ($o[0]+4) ($o[1]+4) ($PanelW-8) ($PanelH-8))); @("as","es","is","os","us") | ForEach-Object -Begin {$i=0} -Process { Tile $g ($o[0]+28+$i*88) ($o[1]+34) 72 52 $_ 0 $_.Length 34 $C.Sand; $i++ }; Caption $g ($o[0]+230) ($o[1]+102) 230 48 "O s no final da sílaba."; Tile $g ($o[0]+28) ($o[1]+210) 190 58 "lá-pis" 3 3 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+255) ($o[1]+210) 190 58 "den-tes" 4 3 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+28) ($o[1]+355) 190 58 "ô-ni-bus" 5 3 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+255) ($o[1]+355) 190 58 "ó-cu-los" 5 3 25 ([System.Drawing.Color]::White); Lis $g ($o[0]+105) ($o[1]+645) .62 "jump"; Tilim $g ($o[0]+372) ($o[1]+548) .55; Bubble $g ($o[0]+22) ($o[1]+505) 280 70 "Lá-pis, den-tes, ô-ni-bus, ó-cu-los!" 20; Bubble $g ($o[0]+270) ($o[1]+590) 210 70 "Agora o s termina a sílaba!" 20
$o=Origin 3; ReadingRoom $g $o[0] $o[1]; Tile $g ($o[0]+50) ($o[1]+105) 168 58 "si-no" 0 2 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+82) ($o[1]+171) 104 38 "início" -1 0 21 $C.Sand; Tile $g ($o[0]+280) ($o[1]+105) 168 58 "fes-ta" 0 3 25 ([System.Drawing.Color]::White); Tile $g ($o[0]+315) ($o[1]+171) 96 38 "final" -1 0 21 $C.Sand; IconText $g ($o[0]+108) ($o[1]+52) "sino" 22 $C.Brown; IconText $g ($o[0]+335) ($o[1]+52) "festa" 22 $C.Brown; Lis $g ($o[0]+230) ($o[1]+610) .78 "point"; Tilim $g ($o[0]+388) ($o[1]+480) .55; Bubble $g ($o[0]+20) ($o[1]+222) 250 64 "Si-no é início. Fes-ta é final!" 20; Bubble $g ($o[0]+22) ($o[1]+300) 260 72 "Vem treinar comigo no portal!" 20; Bubble $g ($o[0]+282) ($o[1]+545) 190 62 "Tem jogo do j e do til!" 20
SavePage $bmp $g (Join-Path $OutDir "hq-sons-letras-j-g-til-s-pg4.png")
