from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math

OUT_DIR = Path(r"C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\portugues\sons-letras-j-g-til-s")
W, H = 1024, 1536
GUTTER = 18
PANEL_W = (W - GUTTER * 3) // 2
PANEL_H = (H - GUTTER * 3) // 2

COLORS = {
    "brown": "#2b140b",
    "burnt": "#7A1F04",
    "orange": "#E8430A",
    "coral": "#FB8C5A",
    "peach": "#FFD2B8",
    "cream": "#FFF4EF",
    "sand": "#F7E9C9",
    "green": "#78B96A",
    "blue": "#62B8E8",
    "grey": "#D6D1C8",
}


def font(size, bold=False):
    names = [
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\segoeuib.ttf" if bold else r"C:\Windows\Fonts\segoeui.ttf",
        r"C:\Windows\Fonts\calibrib.ttf" if bold else r"C:\Windows\Fonts\calibri.ttf",
    ]
    for name in names:
        if Path(name).exists():
            return ImageFont.truetype(name, size=size)
    return ImageFont.load_default()


F = {
    "tiny": font(18, True),
    "small": font(21, True),
    "body": font(25, True),
    "bubble": font(24, True),
    "caption": font(23, True),
    "tile": font(34, True),
    "big": font(48, True),
    "cover": font(31, True),
}


def panel_origin(idx):
    col = idx % 2
    row = idx // 2
    return GUTTER + col * (PANEL_W + GUTTER), GUTTER + row * (PANEL_H + GUTTER)


def make_page():
    img = Image.new("RGB", (W, H), "white")
    d = ImageDraw.Draw(img)
    for i in range(4):
        x, y = panel_origin(i)
        d.rounded_rectangle([x, y, x + PANEL_W, y + PANEL_H], radius=0, fill=COLORS["cream"], outline="black", width=6)
    return img, d


def local(draw, box, fill=COLORS["cream"]):
    x, y, w, h = box
    draw.rectangle([x + 4, y + 4, x + w - 4, y + h - 4], fill=fill)


def text_bbox(draw, xy, txt, f):
    return draw.textbbox(xy, txt, font=f)


def centered_text(draw, rect, txt, f, fill=COLORS["brown"]):
    x1, y1, x2, y2 = rect
    b = text_bbox(draw, (0, 0), txt, f)
    draw.text((x1 + (x2 - x1 - (b[2] - b[0])) / 2, y1 + (y2 - y1 - (b[3] - b[1])) / 2 - 2), txt, font=f, fill=fill)


def wrap_text(draw, text, f, max_w):
    words = text.split(" ")
    lines, cur = [], ""
    for word in words:
        test = word if not cur else cur + " " + word
        if text_bbox(draw, (0, 0), test, f)[2] <= max_w:
            cur = test
        else:
            if cur:
                lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def bubble(draw, x, y, w, h, text, size="bubble"):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=22, fill="white", outline="black", width=4)
    f = F[size]
    lines = wrap_text(draw, text, f, w - 24)
    line_h = f.size + 5
    yy = y + (h - line_h * len(lines)) / 2 - 2
    for line in lines:
        b = text_bbox(draw, (0, 0), line, f)
        draw.text((x + (w - (b[2] - b[0])) / 2, yy), line, font=f, fill=COLORS["brown"])
        yy += line_h


def caption(draw, x, y, w, h, text):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=10, fill=COLORS["cream"], outline=COLORS["orange"], width=4)
    centered_text(draw, [x, y, x + w, y + h], text, F["caption"])


def word_tile(draw, x, y, w, h, text, highlight=None, font_key="tile", fill=COLORS["sand"], outline="black"):
    draw.rounded_rectangle([x, y, x + w, y + h], radius=16, fill=fill, outline=outline, width=4)
    f = F[font_key]
    total = text_bbox(draw, (0, 0), text, f)[2]
    xx = x + (w - total) / 2
    yy = y + (h - f.size) / 2 - 4
    if not highlight:
        draw.text((xx, yy), text, font=f, fill=COLORS["brown"])
        return
    spans = highlight if isinstance(highlight, list) else [highlight]
    for i, ch in enumerate(text):
        color = COLORS["orange"] if any(a <= i < b for a, b in spans) else COLORS["brown"]
        draw.text((xx, yy), ch, font=f, fill=color)
        xx += text_bbox(draw, (0, 0), ch, f)[2]


def syllable_card(draw, x, y, text, w=72, h=52):
    word_tile(draw, x, y, w, h, text, highlight=(0, len(text)), font_key="body")


def draw_lis(draw, cx, cy, scale=1.0, pose="happy"):
    s = scale
    skin = "#F5B38D"
    hair = "#6B2D10"
    # hair mass
    draw.ellipse([cx - 58*s, cy - 145*s, cx + 58*s, cy - 25*s], fill=hair, outline="black", width=max(2, int(3*s)))
    for i in range(7):
        ox = (-48 + i * 16) * s
        draw.arc([cx + ox - 12*s, cy - 138*s, cx + ox + 34*s, cy - 32*s], 90, 300, fill="#351408", width=max(2, int(3*s)))
    # face
    draw.ellipse([cx - 39*s, cy - 122*s, cx + 39*s, cy - 42*s], fill=skin, outline="black", width=max(2, int(3*s)))
    draw.arc([cx - 42*s, cy - 126*s, cx + 8*s, cy - 72*s], 190, 330, fill="#3B1608", width=max(3, int(5*s)))
    # clips
    for dy in [0, 12]:
        draw.rounded_rectangle([cx - 54*s, cy - 103*s + dy*s, cx - 24*s, cy - 94*s + dy*s], radius=4, fill=COLORS["orange"], outline=COLORS["burnt"], width=1)
    # eyes
    draw.ellipse([cx - 26*s, cy - 93*s, cx - 7*s, cy - 70*s], fill="white", outline="black", width=2)
    draw.ellipse([cx + 10*s, cy - 93*s, cx + 29*s, cy - 70*s], fill="white", outline="black", width=2)
    draw.ellipse([cx - 19*s, cy - 88*s, cx - 8*s, cy - 75*s], fill="#5A260E")
    draw.ellipse([cx + 17*s, cy - 88*s, cx + 28*s, cy - 75*s], fill="#5A260E")
    draw.ellipse([cx - 15*s, cy - 86*s, cx - 10*s, cy - 81*s], fill="white")
    draw.ellipse([cx + 21*s, cy - 86*s, cx + 26*s, cy - 81*s], fill="white")
    if pose == "surprise":
        draw.ellipse([cx - 9*s, cy - 66*s, cx + 9*s, cy - 48*s], fill="#5A1208")
    elif pose == "think":
        draw.arc([cx - 13*s, cy - 63*s, cx + 17*s, cy - 43*s], 20, 160, fill="#5A1208", width=max(2, int(3*s)))
    else:
        draw.arc([cx - 22*s, cy - 70*s, cx + 24*s, cy - 39*s], 0, 180, fill="#5A1208", width=max(3, int(4*s)))
    # body
    draw.rounded_rectangle([cx - 33*s, cy - 42*s, cx + 33*s, cy + 40*s], radius=12, fill=COLORS["orange"], outline="black", width=max(2, int(3*s)))
    draw.rectangle([cx - 28*s, cy - 42*s, cx + 28*s, cy - 5*s], fill="#FFF9ED", outline="black", width=max(1, int(2*s)))
    draw.arc([cx - 8*s, cy - 32*s, cx + 12*s, cy - 21*s], 15, 165, fill=COLORS["orange"], width=max(2, int(3*s)))
    draw.rectangle([cx - 28*s, cy + 22*s, cx - 5*s, cy + 69*s], fill=COLORS["orange"], outline="black", width=max(2, int(3*s)))
    draw.rectangle([cx + 5*s, cy + 22*s, cx + 28*s, cy + 69*s], fill=COLORS["orange"], outline="black", width=max(2, int(3*s)))
    # bag
    draw.polygon([(cx + 38*s, cy - 25*s), (cx + 75*s, cy + 16*s), (cx + 58*s, cy + 70*s), (cx + 24*s, cy + 35*s)], fill="#FFF2D7", outline="black")
    draw.text((cx + 47*s, cy + 18*s), "A", font=font(max(14, int(28*s)), True), fill=COLORS["orange"])
    # limbs
    if pose == "jump":
        arms = [((cx - 32*s, cy - 20*s), (cx - 78*s, cy - 83*s)), ((cx + 32*s, cy - 20*s), (cx + 75*s, cy - 84*s))]
    elif pose == "point":
        arms = [((cx - 32*s, cy - 18*s), (cx - 62*s, cy + 15*s)), ((cx + 32*s, cy - 18*s), (cx + 93*s, cy - 50*s))]
    else:
        arms = [((cx - 32*s, cy - 18*s), (cx - 62*s, cy + 5*s)), ((cx + 32*s, cy - 18*s), (cx + 62*s, cy + 5*s))]
    for a, b in arms:
        draw.line([a, b], fill=skin, width=max(5, int(9*s)))
        draw.ellipse([b[0]-5*s, b[1]-5*s, b[0]+5*s, b[1]+5*s], fill=skin, outline="black")
    for lx in [-16, 16]:
        draw.rectangle([cx + lx*s - 8*s, cy + 68*s, cx + lx*s + 8*s, cy + 105*s], fill=COLORS["coral"], outline="black", width=max(1, int(2*s)))
        draw.rounded_rectangle([cx + lx*s - 18*s, cy + 101*s, cx + lx*s + 22*s, cy + 116*s], radius=8, fill="white", outline="black", width=max(1, int(2*s)))
        draw.line([cx + lx*s - 5*s, cy + 107*s, cx + lx*s + 12*s, cy + 106*s], fill=COLORS["orange"], width=max(1, int(2*s)))


def draw_tilim(draw, cx, cy, scale=1.0, mood="happy", transform=None):
    s = scale
    if transform == "s":
        pts = [(cx+20*s, cy-70*s), (cx-45*s, cy-65*s), (cx-55*s, cy-15*s), (cx+25*s, cy-5*s), (cx+50*s, cy+40*s), (cx-30*s, cy+70*s)]
    elif transform == "j":
        pts = [(cx+22*s, cy-70*s), (cx+10*s, cy-20*s), (cx+8*s, cy+45*s), (cx-36*s, cy+62*s), (cx-52*s, cy+25*s)]
    elif transform == "g":
        pts = [(cx+45*s, cy-40*s), (cx-40*s, cy-50*s), (cx-58*s, cy+18*s), (cx+18*s, cy+48*s), (cx+55*s, cy+6*s), (cx+12*s, cy-2*s)]
    elif transform == "zig":
        pts = [(cx-58*s, cy-32*s), (cx-12*s, cy-58*s), (cx+10*s, cy-12*s), (cx+58*s, cy-35*s), (cx+22*s, cy+35*s), (cx-38*s, cy+45*s)]
    else:
        pts = [(cx-62*s, cy+18*s), (cx-30*s, cy-34*s), (cx+8*s, cy+30*s), (cx+58*s, cy-18*s)]
    width = max(18, int(36*s))
    for off, color in [(0, COLORS["orange"]), (width//5, COLORS["coral"])]:
        draw.line(pts, fill=color, width=width-off, joint="curve")
    draw.line(pts, fill="black", width=max(2, int(3*s)), joint="curve")
    # face
    draw.ellipse([cx-29*s, cy-33*s, cx-8*s, cy-4*s], fill="white", outline="black", width=2)
    draw.ellipse([cx+7*s, cy-35*s, cx+29*s, cy-5*s], fill="white", outline="black", width=2)
    draw.ellipse([cx-20*s, cy-24*s, cx-10*s, cy-10*s], fill="#3b1409")
    draw.ellipse([cx+14*s, cy-25*s, cx+24*s, cy-11*s], fill="#3b1409")
    draw.ellipse([cx-17*s, cy-22*s, cx-13*s, cy-18*s], fill="white")
    draw.ellipse([cx+18*s, cy-23*s, cx+22*s, cy-19*s], fill="white")
    draw.ellipse([cx-12*s, cy-48*s, cx+14*s, cy-21*s], fill="#FFD2B8", outline=COLORS["burnt"], width=2)
    if mood == "sad":
        draw.arc([cx-22*s, cy+6*s, cx+25*s, cy+33*s], 200, 340, fill=COLORS["burnt"], width=max(2, int(4*s)))
    else:
        draw.arc([cx-35*s, cy-1*s, cx+38*s, cy+43*s], 0, 180, fill=COLORS["burnt"], width=max(3, int(5*s)))
    draw.arc([cx-37*s, cy-58*s, cx-12*s, cy-43*s], 210, 330, fill=COLORS["burnt"], width=max(2, int(4*s)))
    draw.arc([cx+10*s, cy-60*s, cx+35*s, cy-45*s], 210, 330, fill=COLORS["burnt"], width=max(2, int(4*s)))
    # arms and hat
    draw.line([cx-58*s, cy+6*s, cx-85*s, cy-15*s], fill=COLORS["orange"], width=max(3, int(5*s)))
    draw.line([cx+58*s, cy+2*s, cx+85*s, cy-18*s], fill=COLORS["orange"], width=max(3, int(5*s)))
    draw.arc([cx-54*s, cy-67*s, cx+3*s, cy-30*s], 190, 350, fill="#FFF2D7", width=max(8, int(12*s)))
    for i in range(3):
        bx = cx + (55 + i * 22) * s
        by = cy - (50 - i * 14) * s
        draw.ellipse([bx, by, bx+13*s, by+13*s], fill="#F9C436", outline="#E8A400")


def draw_bookshelf(draw, x, y):
    draw.rectangle([x, y, x + 100, y + 250], fill="#9E5B28", outline="black", width=3)
    for yy in [y + 70, y + 145, y + 220]:
        draw.line([x, yy, x + 100, yy], fill="black", width=3)
    colors = ["#2867B2", "#E8430A", "#78B96A", "#F7C948", "#7B61FF"]
    for row in range(3):
        for i in range(5):
            draw.rectangle([x + 8 + i*17, y + 12 + row*75, x + 20 + i*17, y + 65 + row*75], fill=colors[(i+row)%len(colors)], outline="black")


def draw_window(draw, x, y, w=110, h=120):
    draw.rectangle([x, y, x+w, y+h], fill="#BFE9FF", outline="black", width=3)
    draw.line([x+w/2, y, x+w/2, y+h], fill="black", width=2)
    draw.rectangle([x-18, y-8, x, y+h+8], fill=COLORS["coral"], outline="black")
    draw.rectangle([x+w, y-8, x+w+18, y+h+8], fill=COLORS["coral"], outline="black")


def draw_reading_room(draw, ox, oy):
    draw_window(draw, ox+35, oy+45)
    draw.polygon([(ox+35, oy+165), (ox+215, oy+390), (ox+165, oy+390), (ox+35, oy+230)], fill="#FFE8AA")
    draw_bookshelf(draw, ox+360, oy+70)
    draw.ellipse([ox+105, oy+520, ox+360, oy+675], fill="#D8A86B", outline="black", width=3)
    draw.ellipse([ox+25, oy+340, ox+125, oy+520], fill="#6EB86C", outline="black")
    draw.rectangle([ox+52, oy+505, ox+98, oy+560], fill="#A76533", outline="black")


def draw_book(draw, x, y, w, h, title=True):
    draw.rounded_rectangle([x, y, x+w, y+h], radius=18, fill="#2E77C6", outline="black", width=4)
    draw.rectangle([x+12, y+18, x+w-12, y+h-16], outline="#F5CC45", width=3)
    if title:
        centered_text(draw, [x+10, y+20, x+w-10, y+90], "João e o", F["cover"], "white")
        centered_text(draw, [x+10, y+62, x+w-10, y+132], "Feijoeiro Mágico", F["cover"], "white")
    draw.line([x+w/2, y+142, x+w/2, y+240], fill="#3FA35B", width=6)
    for yy in [160, 190, 220]:
        draw.ellipse([x+w/2, y+yy, x+w/2+45, y+yy+24], fill="#58BD66", outline="black")
        draw.ellipse([x+w/2-45, y+yy+5, x+w/2, y+yy+29], fill="#58BD66", outline="black")
    draw.cloud = None
    draw.ellipse([x+85, y+100, x+185, y+140], fill="white", outline="black")
    draw.rectangle([x+120, y+80, x+155, y+113], fill="#E5C66D", outline="black")


def icon(draw, kind, x, y, s=1):
    if kind == "jeep":
        draw.rectangle([x, y+15*s, x+52*s, y+42*s], fill="#75AADB", outline="black", width=2)
        draw.ellipse([x+6*s, y+35*s, x+20*s, y+49*s], fill="black")
        draw.ellipse([x+34*s, y+35*s, x+48*s, y+49*s], fill="black")
    elif kind == "shop":
        draw.rectangle([x, y+18*s, x+54*s, y+52*s], fill="#FAD28D", outline="black", width=2)
        draw.polygon([(x, y+18*s), (x+27*s, y), (x+54*s, y+18*s)], fill=COLORS["coral"], outline="black")
    elif kind == "eyes":
        draw.ellipse([x, y+10*s, x+24*s, y+34*s], fill="white", outline="black")
        draw.ellipse([x+30*s, y+10*s, x+54*s, y+34*s], fill="white", outline="black")
        draw.ellipse([x+9*s, y+17*s, x+17*s, y+27*s], fill="black")
        draw.ellipse([x+39*s, y+17*s, x+47*s, y+27*s], fill="black")
    elif kind == "calendar":
        draw.rectangle([x, y, x+50*s, y+48*s], fill="white", outline="black", width=2)
        draw.rectangle([x, y, x+50*s, y+14*s], fill=COLORS["coral"], outline="black")
    elif kind == "donkey":
        draw.ellipse([x, y+20*s, x+60*s, y+45*s], fill="#9B8B7A", outline="black")
        draw.polygon([(x+8*s,y+16*s),(x+15*s,y),(x+21*s,y+20*s)], fill="#9B8B7A", outline="black")
    elif kind == "ice":
        draw.polygon([(x+8*s,y+8*s),(x+45*s,y),(x+55*s,y+38*s),(x+18*s,y+50*s)], fill="#BEEBFF", outline="black")
    elif kind == "kids":
        draw.ellipse([x+5*s,y,x+25*s,y+20*s], fill="#F3B58F", outline="black")
        draw.ellipse([x+30*s,y,x+50*s,y+20*s], fill="#D89465", outline="black")
    elif kind == "sunflower":
        for a in range(0,360,45):
            px=x+27*s+math.cos(math.radians(a))*20*s; py=y+26*s+math.sin(math.radians(a))*20*s
            draw.ellipse([px-10*s,py-10*s,px+10*s,py+10*s], fill="#FFD344", outline="black")
        draw.ellipse([x+15*s,y+14*s,x+39*s,y+38*s], fill="#7A3B11", outline="black")
    elif kind == "page":
        draw.rectangle([x+8*s,y,x+48*s,y+55*s], fill="white", outline="black")
        draw.text((x+21*s,y+12*s), "1", font=F["small"], fill=COLORS["brown"])
    elif kind == "rooster":
        draw.ellipse([x+12*s,y+14*s,x+50*s,y+48*s], fill="#F5B657", outline="black")
        draw.polygon([(x+24*s,y+10*s),(x+30*s,y-8*s),(x+36*s,y+10*s)], fill="#D92419", outline="black")
    elif kind == "gorilla":
        draw.ellipse([x+4*s,y+8*s,x+58*s,y+54*s], fill="#6D6D6D", outline="black")
        draw.ellipse([x+18*s,y+22*s,x+44*s,y+46*s], fill="#BFA48A", outline="black")
    elif kind == "face":
        draw.ellipse([x+5*s,y+5*s,x+55*s,y+55*s], fill="#FFD95E", outline="black")
        draw.arc([x+18*s,y+25*s,x+45*s,y+48*s], 0, 180, fill="black", width=3)
    elif kind == "wizard":
        draw.polygon([(x+15*s,y+30*s),(x+31*s,y),(x+47*s,y+30*s)], fill="#7952B3", outline="black")
        draw.ellipse([x+12*s,y+24*s,x+50*s,y+58*s], fill="#F0BE92", outline="black")
    elif kind == "plane":
        draw.polygon([(x,y+24*s),(x+62*s,y+10*s),(x+45*s,y+28*s),(x+62*s,y+45*s)], fill="#9DD8FF", outline="black")
    elif kind == "heart":
        draw.text((x,y), "♥", font=font(int(48*s), True), fill="#D62020")
    elif kind == "lemon":
        draw.ellipse([x+4*s,y+10*s,x+55*s,y+42*s], fill="#F5D735", outline="black")
    elif kind == "bean":
        draw.ellipse([x+10*s,y+9*s,x+52*s,y+42*s], fill="#8C4C23", outline="black")
    elif kind == "apple":
        draw.ellipse([x+8*s,y+10*s,x+54*s,y+55*s], fill="#D82920", outline="black")
        draw.line([x+31*s,y+12*s,x+38*s,y], fill="#5B2F0F", width=3)
    elif kind == "hand":
        draw.ellipse([x+18*s,y+18*s,x+48*s,y+52*s], fill="#F5B38D", outline="black")
        for i in range(4):
            draw.rounded_rectangle([x+i*9*s,y,x+9*s+i*9*s,y+28*s], radius=4, fill="#F5B38D", outline="black")
    elif kind == "pencil":
        draw.polygon([(x,y+42*s),(x+50*s,y+4*s),(x+58*s,y+14*s),(x+8*s,y+52*s)], fill="#F7C948", outline="black")
    elif kind == "teeth":
        draw.rounded_rectangle([x+4*s,y+15*s,x+58*s,y+45*s], radius=16, fill="#B51D18", outline="black")
        draw.rectangle([x+14*s,y+16*s,x+48*s,y+30*s], fill="white", outline="black")
    elif kind == "bus":
        draw.rounded_rectangle([x+2*s,y+12*s,x+64*s,y+48*s], radius=8, fill="#F2C14E", outline="black")
        draw.ellipse([x+10*s,y+42*s,x+24*s,y+56*s], fill="black")
        draw.ellipse([x+42*s,y+42*s,x+56*s,y+56*s], fill="black")
    elif kind == "glasses":
        draw.ellipse([x+4*s,y+18*s,x+28*s,y+42*s], fill="none", outline="black", width=3)
        draw.ellipse([x+36*s,y+18*s,x+60*s,y+42*s], fill="none", outline="black", width=3)
        draw.line([x+28*s,y+30*s,x+36*s,y+30*s], fill="black", width=3)


def page1():
    img, d = make_page()
    # p1
    ox, oy = panel_origin(0); local(d, (ox, oy, PANEL_W, PANEL_H)); draw_reading_room(d, ox, oy)
    draw_lis(d, ox+230, oy+455, .95, "surprise")
    draw_book(d, ox+132, oy+215, 245, 290)
    draw_tilim(d, ox+253, oy+205, .55, "happy")
    d.rectangle([ox+130, oy+210, ox+380, oy+290], fill="#2E77C6")
    centered_text(d, [ox+140, oy+220, ox+370, oy+276], "João e o", F["cover"], "white")
    bubble(d, ox+28, oy+38, 290, 72, "João e o Feijoeiro Mágico!")
    # p2
    ox, oy = panel_origin(1); local(d, (ox, oy, PANEL_W, PANEL_H)); draw_reading_room(d, ox, oy)
    draw_book(d, ox+28, oy+190, 250, 300, False)
    word_tile(d, ox+64, oy+234, 175, 78, "João", highlight=[(0,1)], font_key="big", fill="#FFFFFF")
    draw_tilim(d, ox+172, oy+210, .72)
    draw_lis(d, ox+360, oy+500, .82, "surprise")
    bubble(d, ox+205, oy+52, 255, 96, "Oi! Eu moro em cima do ão!")
    bubble(d, ox+242, oy+158, 210, 100, "Você mora dentro do livro?")
    # p3
    ox, oy = panel_origin(2); local(d, (ox, oy, PANEL_W, PANEL_H))
    caption(d, ox+22, oy+24, 285, 54, "O som do j é sempre o mesmo.")
    for i, syl in enumerate(["ja","je","ji","jo","ju"]):
        syllable_card(d, ox+32+i*86, oy+130, syl)
        for r in range(3):
            d.arc([ox+47+i*86-r*9, oy+194-r*8, ox+103+i*86+r*9, oy+238+r*8], 220, 320, fill=COLORS["orange"], width=3)
    draw_tilim(d, ox+190, oy+365, .75, transform="j")
    draw_lis(d, ox+390, oy+535, .72, "think")
    bubble(d, ox+66, oy+455, 285, 86, "Ja, je, ji, jo, ju — mesmo som!")
    bubble(d, ox+210, oy+585, 250, 78, "Com toda vogal ele não muda?")
    # p4
    ox, oy = panel_origin(3); local(d, (ox, oy, PANEL_W, PANEL_H))
    entries=[("jipe","jeep"),("loja","shop"),("vejo","eyes"),("julho","calendar"),("jegue","donkey")]
    coords=[(36,118),(204,74),(360,130),(110,304),(290,315)]
    for (txt, kind),(dx,dy) in zip(entries,coords):
        icon(d, kind, ox+dx+42, oy+dy-55, .8)
        hi=(txt.index("j"), txt.index("j")+1)
        word_tile(d, ox+dx, oy+dy, 140, 60, txt, highlight=hi, font_key="body")
    for i in range(28):
        x=ox+20+(i*73)%450; y=oy+25+(i*47)%640
        d.text((x,y), "j", font=F["small"], fill=COLORS["orange"])
    draw_lis(d, ox+155, oy+595, .72, "jump")
    draw_tilim(d, ox+358, oy+560, .62, transform="zig")
    bubble(d, ox+18, oy+430, 285, 78, "Jipe, loja, vejo, julho, jegue!")
    bubble(d, ox+258, oy+470, 210, 84, "Isso! O j nunca me engana!")
    return img


def page2():
    img, d = make_page()
    ox, oy = panel_origin(0); local(d, (ox, oy, PANEL_W, PANEL_H))
    draw_window(d, ox+320, oy+44, 100, 105)
    d.rectangle([ox+0, oy+240, ox+PANEL_W, oy+PANEL_H-4], fill="#F6D8B8")
    d.rectangle([ox+26, oy+350, ox+230, oy+470], fill="#C58A4D", outline="black", width=3)
    d.rectangle([ox+300, oy+120, ox+455, oy+310], fill="#D8EEF5", outline="black", width=4)
    d.rectangle([ox+320, oy+150, ox+455, oy+290], fill="#FFFFFF", outline="black", width=3)
    for i in range(7):
        d.rectangle([ox+280+i*18, oy+180+i*8, ox+450+i*7, oy+400+i*3], fill="#FFFFFF")
    word_tile(d, ox+144, oy+170, 210, 74, "gelo", highlight=(0,1), font_key="big", fill="#E9FAFF")
    for x in [180,230,300]: icon(d, "ice", ox+x, oy+120, .55)
    draw_lis(d, ox+126, oy+590, .75, "surprise")
    draw_tilim(d, ox+388, oy+410, .6)
    bubble(d, ox+165, oy+36, 292, 74, "Escuta o g dessa palavra aqui!")
    bubble(d, ox+32, oy+75, 235, 70, "Parece o som do j!")
    # p2
    ox, oy = panel_origin(1); local(d, (ox, oy, PANEL_W, PANEL_H))
    caption(d, ox+16, oy+20, 180, 48, "Antes de e ou i,")
    word_tile(d, ox+175, oy+68, 150, 50, "g + e / i", highlight=(0,1), font_key="caption")
    tiles=[("gelo","ice"),("gente","kids"),("girassol","sunflower"),("página","page")]
    coords=[(88,170),(275,170),(88,306),(275,306)]
    for (txt,kind),(dx,dy) in zip(tiles,coords):
        icon(d, kind, ox+dx-62, oy+dy+3, .75)
        word_tile(d, ox+dx, oy+dy, 160, 58, txt, highlight=(0,1), font_key="body")
        d.arc([ox+dx+45, oy+dy-50, ox+dx+115, oy+dy-5], 200, 340, fill=COLORS["orange"], width=3)
    caption(d, ox+230, oy+470, 240, 58, "o g tem som igual ao do j.")
    draw_tilim(d, ox+230, oy+505, .64, transform="g")
    draw_lis(d, ox+398, oy+625, .58, "happy")
    bubble(d, ox+54, oy+560, 300, 72, "Gelo, gente, girassol, página!")
    # p3
    ox, oy = panel_origin(2); local(d, (ox, oy, PANEL_W, PANEL_H), COLORS["sand"])
    d.rectangle([ox+20, oy+340, ox+470, oy+365], fill="#B87535", outline="black")
    d.ellipse([ox+340, oy+80, ox+480, oy+270], fill="#73B760", outline="black")
    word_tile(d, ox+172, oy+58, 180, 52, "g + a / o / u", highlight=(0,1), font_key="caption")
    caption(d, ox+265, oy+125, 200, 48, "Antes de a, o e u,")
    caption(d, ox+26, oy+548, 230, 52, "o g tem som diferente.")
    entries=[("galo","rooster"),("gorila","gorilla"),("guloso","face"),("mago","wizard")]
    for i,(txt,kind) in enumerate(entries):
        x=ox+24+i*112
        icon(d, kind, x+20, oy+215, .75)
        word_tile(d, x, oy+285, 102, 56, txt, highlight=(0,1), font_key="small")
        d.arc([x+18, oy+355, x+90, oy+415], 210, 330, fill=COLORS["burnt"], width=7)
    draw_tilim(d, ox+118, oy+470, .7, "sad")
    draw_lis(d, ox+376, oy+570, .65, "happy")
    bubble(d, ox+250, oy+405, 220, 72, "Aqui o g mudou de voz!")
    bubble(d, ox+24, oy+420, 210, 82, "O g é fofoqueiro mesmo!")
    # p4
    ox, oy = panel_origin(3); local(d, (ox, oy, PANEL_W, PANEL_H))
    d.line([ox+PANEL_W/2, oy+20, ox+PANEL_W/2, oy+PANEL_H-20], fill=COLORS["orange"], width=4)
    for yy in range(30, PANEL_H-30, 30):
        d.line([ox+PANEL_W/2, oy+yy, ox+PANEL_W/2, oy+yy+12], fill=COLORS["cream"], width=5)
    d.line([ox+210,oy+306, ox+317, oy+306], fill=COLORS["orange"], width=8)
    d.polygon([(ox+210,oy+306),(ox+230,oy+294),(ox+230,oy+318)], fill=COLORS["orange"])
    d.polygon([(ox+317,oy+306),(ox+297,oy+294),(ox+297,oy+318)], fill=COLORS["orange"])
    word_tile(d, ox+35, oy+200, 200, 70, "feijoeiro", highlight=(3,4), font_key="body", fill="white")
    word_tile(d, ox+285, oy+200, 175, 70, "mágico", highlight=(2,3), font_key="body", fill="white")
    word_tile(d, ox+196, oy+278, 140, 48, "mesmo som", font_key="small", fill="#FFE5EF")
    draw_lis(d, ox+250, oy+600, .7, "jump")
    draw_tilim(d, ox+255, oy+415, .58)
    bubble(d, ox+22, oy+420, 270, 84, "Feijoeiro e mágico têm o mesmo som!")
    bubble(d, ox+260, oy+455, 205, 82, "Acertou! O g virou j aqui!")
    return img


def page3():
    img, d = make_page()
    # p1
    ox, oy = panel_origin(0); local(d, (ox, oy, PANEL_W, PANEL_H))
    d.rectangle([ox+0, oy+90, ox+PANEL_W, oy+170], fill=COLORS["coral"], outline="black")
    for i in range(3):
        d.rectangle([ox+40, oy+210+i*78, ox+440, oy+260+i*78], fill="#A76B34", outline="black")
        for j in range(5):
            d.ellipse([ox+65+j*72, oy+218+i*78, ox+112+j*72, oy+250+i*78], fill="#D99B3B", outline="black")
    d.rectangle([ox+20, oy+430, ox+465, oy+560], fill="#CFE9F2", outline="black", width=3)
    word_tile(d, ox+145, oy+145, 190, 72, "pao", font_key="big", fill=COLORS["grey"], outline="#777777")
    for i in range(3): d.text((ox+170+i*50, oy+80), "?", font=F["big"], fill="#8A8780")
    draw_lis(d, ox+92, oy+650, .62, "think")
    draw_tilim(d, ox+380, oy+265, .58, "sad")
    bubble(d, ox+24, oy+34, 250, 68, "Essa palavra está estranha!")
    bubble(d, ox+225, oy+345, 235, 86, "A palavra tá pelada! Segura aí!")
    # p2
    ox, oy = panel_origin(1); local(d, (ox, oy, PANEL_W, PANEL_H))
    for r in range(40,260,24):
        d.ellipse([ox+245-r, oy+230-r, ox+245+r, oy+230+r], outline="#FFD3A4", width=3)
    caption(d, ox+22, oy+24, 250, 50, "O til marca o som nasal.")
    word_tile(d, ox+154, oy+178, 190, 84, "pão", highlight=(0,2), font_key="big", fill="#FFFFFF")
    draw_tilim(d, ox+236, oy+146, .38)
    icon(d, "bean", ox+206, oy+310, 1.0)
    d.ellipse([ox+180, oy+340, ox+330, oy+410], fill="#D99B3B", outline="black", width=3)
    draw_lis(d, ox+394, oy+615, .58, "surprise")
    bubble(d, ox+48, oy+425, 305, 84, "Ãããã! Isso aí é pra cantar no nariz!")
    bubble(d, ox+260, oy+530, 200, 72, "Virou pão de verdade!")
    # p3
    ox, oy = panel_origin(2); local(d, (ox, oy, PANEL_W, PANEL_H))
    for i in range(10):
        d.polygon([(ox+20+i*44, oy+40),(ox+42+i*44,oy+40),(ox+31+i*44,oy+65)], fill=COLORS["orange"], outline="black")
    d.rectangle([ox+40, oy+430, ox+340, oy+480], fill="#9E5B28", outline="black", width=3)
    word_tile(d, ox+42, oy+130, 116, 56, "mao", font_key="body", fill=COLORS["grey"])
    d.line([ox+176,oy+158, ox+248,oy+158], fill=COLORS["orange"], width=6); d.polygon([(ox+248,oy+158),(ox+232,oy+148),(ox+232,oy+168)], fill=COLORS["orange"])
    word_tile(d, ox+268, oy+130, 122, 56, "mão", highlight=(1,2), font_key="body", fill="white"); icon(d, "hand", ox+398, oy+118, .8)
    word_tile(d, ox+42, oy+275, 116, 56, "maca", font_key="body", fill=COLORS["grey"])
    d.line([ox+176,oy+303, ox+248,oy+303], fill=COLORS["orange"], width=6); d.polygon([(ox+248,oy+303),(ox+232,oy+293),(ox+232,oy+313)], fill=COLORS["orange"])
    word_tile(d, ox+268, oy+275, 132, 56, "maçã", highlight=[(2,4)], font_key="body", fill="white"); icon(d, "apple", ox+408, oy+260, .8)
    draw_tilim(d, ox+230, oy+420, .56)
    draw_lis(d, ox+410, oy+650, .58, "happy")
    bubble(d, ox+24, oy+515, 270, 82, "Ponho o chapeuzinho e a palavra muda!")
    bubble(d, ox+250, oy+510, 220, 78, "Mão e maçã! Que mágica boa!")
    # p4
    ox, oy = panel_origin(3); local(d, (ox, oy, PANEL_W, PANEL_H))
    fam=[("ão",50,82),("ãe",270,82),("õe",50,362),("ã",270,362)]
    for txt,dx,dy in fam:
        word_tile(d, ox+dx, oy+dy, 145, 66, txt, highlight=(0,len(txt)), font_key="big")
        if txt in ["ãe","õe"]:
            d.text((ox+dx+58, oy+dy-48), "♪", font=F["big"], fill=COLORS["orange"])
    words=[("avião","plane"),("coração","heart"),("limão","lemon"),("feijão","bean")]
    for i,(txt,kind) in enumerate(words):
        word_tile(d, ox+62, oy+156+i*48, 150, 40, txt, highlight=(len(txt)-2,len(txt)), font_key="small", fill="white")
        icon(d, kind, ox+218, oy+150+i*48, .55)
    for i,(txt,kind) in enumerate([("romã","apple"),("irmã","kids")]):
        word_tile(d, ox+286, oy+442+i*50, 130, 40, txt, highlight=(len(txt)-1,len(txt)), font_key="small", fill="white")
        icon(d, kind, ox+420, oy+435+i*50, .55)
    draw_lis(d, ox+82, oy+662, .57, "jump")
    draw_tilim(d, ox+402, oy+125, .55, transform="zig")
    bubble(d, ox+22, oy+565, 150, 60, "Sem til, é 'pao'.", "small")
    bubble(d, ox+164, oy+555, 210, 74, "Com til, é PÃO! Tcharam!", "small")
    bubble(d, ox+212, oy+635, 250, 60, "Agora eu canto tudo no nariz!", "small")
    return img


def page4():
    img, d = make_page()
    ox, oy = panel_origin(0); local(d, (ox, oy, PANEL_W, PANEL_H))
    draw_window(d, ox+30, oy+64, 90, 105)
    d.rectangle([ox+300,oy+84,ox+468,oy+225], fill="#6AA66A", outline="black", width=4)
    d.rectangle([ox+40,oy+450,ox+210,oy+540], fill="#B87535", outline="black", width=3)
    for i,syl in enumerate(["sa","se","si","so","su"]): syllable_card(d, ox+32+i*86, oy+38, syl)
    draw_tilim(d, ox+228, oy+345, 1.05, transform="s")
    draw_lis(d, ox+392, oy+592, .67, "surprise")
    bubble(d, ox+45, oy+505, 210, 70, "Olha! Virei a letra s!")
    bubble(d, ox+260, oy+500, 190, 66, "Sa, se, si, so, su!")
    # p2
    ox, oy = panel_origin(1); local(d, (ox, oy, PANEL_W, PANEL_H))
    draw_window(d, ox+330, oy+54, 100, 100)
    d.rectangle([ox+20, oy+405, ox+470, oy+610], fill="#FFF7E7", outline="black", width=3)
    caption(d, ox+20, oy+28, 245, 50, "O s no início da sílaba.")
    data=[("sa-la-da",(0,2),"salad"),("su-co",(0,2),"juice"),("sa-pa-to",(0,2),"shoe")]
    xs=[30,185,335]
    for (txt,hi,kind),x in zip(data,xs):
        word_tile(d, ox+x, oy+150, 132, 58, txt, highlight=hi, font_key="small", fill="white")
        d.polygon([(ox+x+18,oy+225),(ox+x+34,oy+225),(ox+x+26,oy+210)], fill=COLORS["orange"])
    d.ellipse([ox+55,oy+310,ox+145,oy+360], fill="#7CBC5D", outline="black", width=3)
    d.rectangle([ox+217,oy+292,ox+255,oy+370], fill="#FFB330", outline="black", width=3)
    d.rounded_rectangle([ox+362,oy+330,ox+450,oy+368], radius=14, fill="white", outline="black", width=3)
    draw_tilim(d, ox+255, oy+302, .55)
    draw_lis(d, ox+416, oy+642, .58, "happy")
    bubble(d, ox+24, oy+520, 226, 72, "Aqui o s começa a sílaba.")
    bubble(d, ox+192, oy+595, 270, 66, "Sa-la-da, su-co, sa-pa-to!")
    # p3
    ox, oy = panel_origin(2); local(d, (ox, oy, PANEL_W, PANEL_H), "#FFE7C5")
    d.rectangle([ox+0,oy+415,ox+PANEL_W,oy+700], fill="#D9C7A8")
    d.rectangle([ox+260,oy+105,ox+460,oy+300], fill="#FFF4EF", outline="black")
    d.rectangle([ox+35,oy+110,ox+120,oy+250], fill="#FFF4EF", outline="black")
    for i,syl in enumerate(["as","es","is","os","us"]): syllable_card(d, ox+28+i*88, oy+34, syl)
    caption(d, ox+230, oy+102, 230, 48, "O s no final da sílaba.")
    entries=[("lá-pis",(3,6),"pencil"),("den-tes",(4,7),"teeth"),("ô-ni-bus",(5,8),"bus"),("ó-cu-los",(5,8),"glasses")]
    coords=[(28,210),(255,210),(28,355),(255,355)]
    for (txt,hi,kind),(dx,dy) in zip(entries,coords):
        icon(d, kind, ox+dx+45, oy+dy-62, .7)
        word_tile(d, ox+dx, oy+dy, 190, 58, txt, highlight=hi, font_key="body", fill="white")
        d.polygon([(ox+dx+150,oy+dy+72),(ox+dx+166,oy+dy+72),(ox+dx+158,oy+dy+58)], fill=COLORS["orange"])
    draw_lis(d, ox+105, oy+645, .62, "jump")
    draw_tilim(d, ox+372, oy+548, .55)
    bubble(d, ox+22, oy+505, 280, 70, "Lá-pis, den-tes, ô-ni-bus, ó-cu-los!", "small")
    bubble(d, ox+270, oy+590, 210, 70, "Agora o s termina a sílaba!", "small")
    # p4
    ox, oy = panel_origin(3); local(d, (ox, oy, PANEL_W, PANEL_H)); draw_reading_room(d, ox, oy)
    d.rounded_rectangle([ox+300,oy+430,ox+455,oy+520], radius=12, fill="#333333", outline="black", width=3)
    d.rectangle([ox+314,oy+444,ox+441,oy+500], fill="#F7A63B")
    for i in range(3):
        d.rounded_rectangle([ox+326+i*35,oy+458,ox+350+i*35,oy+480], radius=8, fill="#FFF4EF")
    d.text((ox+386,oy+438), "~", font=F["big"], fill=COLORS["orange"])
    word_tile(d, ox+50, oy+105, 168, 58, "si-no", highlight=(0,2), font_key="body", fill="white")
    word_tile(d, ox+82, oy+171, 104, 38, "início", font_key="small")
    word_tile(d, ox+280, oy+105, 168, 58, "fes-ta", highlight=(0,3), font_key="body", fill="white")
    word_tile(d, ox+315, oy+171, 96, 38, "final", font_key="small")
    d.text((ox+108,oy+52), "🔔", font=font(34, True), fill=COLORS["orange"])
    for ch,x,y in [("j",50,300),("g",410,270),("s",120,245),("~",390,340)]:
        d.text((ox+x,oy+y), ch, font=F["big"], fill=COLORS["orange"])
    draw_lis(d, ox+230, oy+610, .78, "point")
    draw_tilim(d, ox+388, oy+480, .55)
    bubble(d, ox+20, oy+222, 250, 64, "Si-no é início. Fes-ta é final!", "small")
    bubble(d, ox+22, oy+300, 260, 72, "Vem treinar comigo no portal!", "small")
    bubble(d, ox+282, oy+545, 190, 62, "Tem jogo do j e do til!", "small")
    return img


def main():
    pages = [page1(), page2(), page3(), page4()]
    paths = [
        OUT_DIR / "hq-sons-letras-j-g-til-s-pg1.png",
        OUT_DIR / "hq-sons-letras-j-g-til-s-pg2.png",
        OUT_DIR / "hq-sons-letras-j-g-til-s-pg3.png",
        OUT_DIR / "hq-sons-letras-j-g-til-s-pg4.png",
    ]
    for img, path in zip(pages, paths):
        img.save(path)
        print(f"saved {path} {img.size[0]}x{img.size[1]}")


if __name__ == "__main__":
    main()
