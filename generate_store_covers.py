import os, math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# Color Palette (Paper-Industrial)
C_PAPER = (237, 231, 216)         # #EDE7D8
C_PAPER_DARK = (226, 219, 202)    # slightly darker paper tone
C_CHARCOAL = (36, 37, 33)         # #242521
C_CHARCOAL_MID = (54, 56, 50)     # #363832
C_CHARCOAL_LIGHT = (72, 75, 68)   # #484B44
C_ORANGE = (229, 107, 54)         # #E56B36
C_ORANGE_GLOW = (244, 142, 94)    # #F48E5E
C_SAGE = (167, 179, 160)          # #A7B3A0
C_SAND = (215, 185, 109)          # #D7B96D
C_GRID = (122, 125, 118, 32)      # subtle grid
C_GRID_MAJOR = (122, 125, 118, 55)# major grid
C_WHITE = (255, 255, 255)

FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_MONO = "/System/Library/Fonts/Supplemental/Courier New Bold.ttf"

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.load_default()

def draw_grid_and_technical_marks(draw, width, height, grid_step=32):
    # Minor Grid
    for x in range(0, width, grid_step):
        draw.line([(x, 0), (x, height)], fill=C_GRID, width=1)
    for y in range(0, height, grid_step):
        draw.line([(0, y), (width, y)], fill=C_GRID, width=1)
        
    # Major Grid
    major_step = grid_step * 4
    for x in range(0, width, major_step):
        draw.line([(x, 0), (x, height)], fill=C_GRID_MAJOR, width=1)
    for y in range(0, height, major_step):
        draw.line([(0, y), (width, y)], fill=C_GRID_MAJOR, width=1)

    # Technical Crosshairs at intersections
    cross_size = 5
    for x in range(major_step, width, major_step * 2):
        for y in range(major_step, height, major_step * 2):
            draw.line([(x - cross_size, y), (x + cross_size, y)], fill=(122, 125, 118, 110), width=1)
            draw.line([(x, y - cross_size), (x, y + cross_size)], fill=(122, 125, 118, 110), width=1)

    # Outer architectural frame border
    margin = 16
    draw.rectangle([margin, margin, width - margin, height - margin], outline=C_CHARCOAL, width=2)
    # Technical corner brackets
    bracket_len = 24
    # Top-Left
    draw.line([(margin, margin + bracket_len), (margin, margin), (margin + bracket_len, margin)], fill=C_ORANGE, width=3)
    # Top-Right
    draw.line([(width - margin - bracket_len, margin), (width - margin, margin), (width - margin, margin + bracket_len)], fill=C_ORANGE, width=3)
    # Bottom-Left
    draw.line([(margin, height - margin - bracket_len), (margin, height - margin), (margin + bracket_len, height - margin)], fill=C_ORANGE, width=3)
    # Bottom-Right
    draw.line([(width - margin - bracket_len, height - margin), (width - margin, height - margin), (width - margin, height - margin - bracket_len)], fill=C_ORANGE, width=3)

def draw_hero_runner(image, cx, cy, scale=12.0, facing=1, lean_deg=10.0):
    """
    Renders a giant, hyper-detailed, faceted geometric Unit 01 runner.
    """
    # Create high-res overlay layer for anti-aliased character drawing
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    # Convert coordinates with rotation
    rad = math.radians(lean_deg)
    cos_a = math.cos(rad)
    sin_a = math.sin(rad)

    def tf(x, y):
        # Scale, rotate, and translate
        rx = x * scale * facing
        ry = y * scale
        nx = rx * cos_a - ry * sin_a + cx
        ny = rx * sin_a + ry * cos_a + cy
        return (nx, ny)

    # Body Dimensions (based on player_visual.gd: w=10, h_top=-16, h_bot=14, chamfer=4)
    w = 10.0
    h_top = -16.0
    h_bot = 14.0
    ch = 4.0

    # Dynamic Speed Trail / Shadow Facets Behind Player
    for i in range(3, 0, -1):
        trail_offset_x = -i * 18.0 * facing
        trail_alpha = int(35 / i)
        trail_pts = [
            (tf(-w + ch, h_top)[0] + trail_offset_x, tf(-w + ch, h_top)[1]),
            (tf(w - ch, h_top)[0] + trail_offset_x, tf(w - ch, h_top)[1]),
            (tf(w, h_top + ch)[0] + trail_offset_x, tf(w, h_top + ch)[1]),
            (tf(w, h_bot - ch)[0] + trail_offset_x, tf(w, h_bot - ch)[1]),
            (tf(w - ch, h_bot)[0] + trail_offset_x, tf(w - ch, h_bot)[1]),
            (tf(-w + ch, h_bot)[0] + trail_offset_x, tf(-w + ch, h_bot)[1]),
            (tf(-w, h_bot - ch)[0] + trail_offset_x, tf(-w, h_bot - ch)[1]),
            (tf(-w, h_top + ch)[0] + trail_offset_x, tf(-w, h_top + ch)[1]),
        ]
        draw.polygon(trail_pts, fill=(36, 37, 33, trail_alpha))

    # Contact Shadow on platform
    shadow_w = w * scale * 1.4
    shadow_y = cy + (h_bot * scale) + 12
    draw.ellipse([cx - shadow_w, shadow_y - 6, cx + shadow_w, shadow_y + 6], fill=(36, 37, 33, 70))

    # 1. Main Faceted Charcoal Chassis
    # Left Facet (shadowed)
    p_top_l = tf(-w + ch, h_top)
    p_top_mid = tf(0, h_top)
    p_bot_mid = tf(0, h_bot)
    p_bot_l = tf(-w + ch, h_bot)
    p_mid_bot_l = tf(-w, h_bot - ch)
    p_mid_top_l = tf(-w, h_top + ch)

    # Right Facet (illuminated)
    p_top_r = tf(w - ch, h_top)
    p_mid_top_r = tf(w, h_top + ch)
    p_mid_bot_r = tf(w, h_bot - ch)
    p_bot_r = tf(w - ch, h_bot)

    # Fill Left Side
    draw.polygon([p_top_l, p_top_mid, p_bot_mid, p_bot_l, p_mid_bot_l, p_mid_top_l], fill=C_CHARCOAL)
    # Fill Right Side (slight highlight facet)
    draw.polygon([p_top_mid, p_top_r, p_mid_top_r, p_mid_bot_r, p_bot_r, p_bot_mid], fill=C_CHARCOAL_MID)

    # Outline
    outer_points = [p_top_l, p_top_r, p_mid_top_r, p_mid_bot_r, p_bot_r, p_bot_l, p_mid_bot_l, p_mid_top_l]
    draw.polygon(outer_points, outline=C_CHARCOAL_LIGHT, width=2)

    # 2. Architectural Crease Lines (Sage Green & Sand)
    # Central spine fold
    draw.line([p_top_mid, p_bot_mid], fill=C_SAGE, width=max(2, int(scale * 0.15)))
    # Facet diagonal crease lines
    draw.line([tf(-w + 2, h_top + ch), tf(-2, h_top + ch + 3)], fill=C_SAND, width=max(1, int(scale * 0.1)))
    draw.line([tf(w - 2, h_top + ch), tf(2, h_top + ch + 3)], fill=C_SAND, width=max(1, int(scale * 0.1)))

    # 3. Skid Pads / Industrial Runners
    foot_w = 6.0
    foot_h = 2.8
    # Rear foot
    rf_pts = [tf(-8.0, h_bot - 1), tf(-8.0 + foot_w, h_bot - 1), tf(-8.0 + foot_w, h_bot - 1 + foot_h), tf(-8.0, h_bot - 1 + foot_h)]
    draw.polygon(rf_pts, fill=C_SAND, outline=C_CHARCOAL, width=1)
    # Lead foot (extended forward)
    lf_pts = [tf(2.5, h_bot - 1), tf(2.5 + foot_w, h_bot - 1), tf(2.5 + foot_w, h_bot - 1 + foot_h), tf(2.5, h_bot - 1 + foot_h)]
    draw.polygon(lf_pts, fill=C_SAND, outline=C_CHARCOAL, width=1)

    # 4. Optic Visor (Signal Orange Laser Beam / Flare)
    visor_w = 7.5
    visor_h = 3.6
    visor_cx = 3.5
    visor_cy = -6.0

    # Horizontal Anamorphic Laser Flare Glow across the screen
    flare_len = scale * 14.0
    v_pos = tf(visor_cx, visor_cy)
    draw.line([(v_pos[0] - flare_len, v_pos[1]), (v_pos[0] + flare_len, v_pos[1])], fill=(229, 107, 54, 120), width=int(scale * 0.25))
    draw.line([(v_pos[0] - flare_len * 0.5, v_pos[1]), (v_pos[0] + flare_len * 0.5, v_pos[1])], fill=(244, 142, 94, 200), width=int(scale * 0.4))

    # Visor polygon
    v_tl = tf(visor_cx - visor_w/2, visor_cy - visor_h/2)
    v_tr = tf(visor_cx + visor_w/2, visor_cy - visor_h/2)
    v_br = tf(visor_cx + visor_w/2, visor_cy + visor_h/2)
    v_bl = tf(visor_cx - visor_w/2, visor_cy + visor_h/2)
    draw.polygon([v_tl, v_tr, v_br, v_bl], fill=C_ORANGE, outline=(255, 200, 150), width=1)

    # Bright White Specular Core
    core_pos = tf(visor_cx + 1.2, visor_cy)
    draw.ellipse([core_pos[0] - scale * 0.16, core_pos[1] - scale * 0.16, core_pos[0] + scale * 0.16, core_pos[1] + scale * 0.16], fill=C_WHITE)

    # 5. Dynamic Kinetic Paper Shards (trailing in the wind)
    shard_defs = [
        [(-16, -18), (-22, -26), (-20, -14)],
        [(-18, 4), (-25, 2), (-22, 10)],
        [(-14, 16), (-20, 24), (-15, 22)],
        [(14, -20), (18, -26), (20, -18)],
        [(-24, -8), (-32, -10), (-28, -4)]
    ]
    shard_colors = [C_CHARCOAL, C_ORANGE, C_SAND, C_SAGE, C_CHARCOAL_MID]
    for s_idx, pts in enumerate(shard_defs):
        mapped = [tf(px, py) for px, py in pts]
        draw.polygon(mapped, fill=shard_colors[s_idx % len(shard_colors)])

    # Composite
    image.alpha_composite(overlay)

def draw_time_fragment(image, x, y, size=36):
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    # Diamond / Rhombus Shard
    pts = [(x, y - size), (x + size * 0.65, y), (x, y + size), (x - size * 0.65, y)]
    # Glow ring
    draw.polygon([(x, y - size*1.2), (x + size*0.8, y), (x, y + size*1.2), (x - size*0.8, y)], fill=(229, 107, 54, 45))
    # Outer diamond
    draw.polygon(pts, fill=C_ORANGE, outline=C_SAND, width=2)
    # Inner facet
    pts_inner = [(x, y - size * 0.6), (x + size * 0.4, y), (x, y + size * 0.6), (x - size * 0.4, y)]
    draw.polygon(pts_inner, fill=C_SAND)
    
    f_mono = get_font(FONT_MONO, 14)
    draw.text((x + size * 0.8, y - 8), "+2.0s", fill=C_CHARCOAL, font=f_mono)
    image.alpha_composite(overlay)

def draw_spikes_strip(draw, x_start, y, width, count=8, height=18):
    step = width / count
    for i in range(count):
        bx = x_start + i * step
        pts = [(bx, y), (bx + step / 2, y - height), (bx + step, y)]
        draw.polygon(pts, fill=C_CHARCOAL, outline=C_ORANGE, width=1)

def render_playstore_feature_graphic(out_path):
    # Google Play Store: 1024 x 500
    width = 1024
    height = 500
    img = Image.new("RGBA", (width, height), C_PAPER)
    draw = ImageDraw.Draw(img)

    draw_grid_and_technical_marks(draw, width, height, grid_step=32)

    # Platforms
    # Main hero platform (right side beneath runner)
    plat_x = 540
    plat_y = 390
    plat_w = 420
    plat_h = 36
    draw.rectangle([plat_x, plat_y, plat_x + plat_w, plat_y + plat_h], fill=C_CHARCOAL)
    # Technical markings on platform edge
    for tx in range(plat_x + 10, plat_x + plat_w, 20):
        draw.line([(tx, plat_y), (tx, plat_y + 4)], fill=C_SAND, width=1)
    
    # Left lower platform
    draw.rectangle([40, 430, 240, 470], fill=C_CHARCOAL)
    
    # Hazard spikes beneath the gap
    draw_spikes_strip(draw, 250, 480, 280, count=12, height=22)

    # Hero Runner (Center-Right, Scale 13x)
    draw_hero_runner(img, cx=740, cy=240, scale=13.0, facing=1, lean_deg=12.0)

    # Time Fragment Floating
    draw_time_fragment(img, x=940, y=140, size=24)

    # Left Section: Typography & Branding
    f_title = get_font(FONT_BOLD, 78)
    f_sub = get_font(FONT_BOLD, 14)
    f_mono_large = get_font(FONT_MONO, 38)
    f_mono_small = get_font(FONT_MONO, 12)

    # Title: CLICK
    title_x = 60
    title_y = 80
    draw.text((title_x, title_y), "CLICK", fill=C_CHARCOAL, font=f_title)

    # Signal Orange Accent Rule
    bar_y = title_y + 86
    draw.rectangle([title_x, bar_y, title_x + 180, bar_y + 6], fill=C_ORANGE)

    # Subtitle
    draw.text((title_x, bar_y + 16), "PRECISION 10-SECOND PLATFORMER", fill=C_CHARCOAL_MID, font=f_sub)

    # 10-Second Digital Timer HUD Card
    timer_box_x = title_x
    timer_box_y = bar_y + 46
    draw.rectangle([timer_box_x, timer_box_y, timer_box_x + 280, timer_box_y + 90], fill=C_CHARCOAL, outline=C_ORANGE, width=2)
    draw.text((timer_box_x + 14, timer_box_y + 10), "COUNTDOWN MATRIX", fill=C_SAGE, font=f_mono_small)
    # Large glowing timer numbers: 09:84
    draw.text((timer_box_x + 14, timer_box_y + 32), "09:84", fill=C_ORANGE, font=f_mono_large)
    draw.text((timer_box_x + 175, timer_box_y + 46), "SEC.FRM", fill=C_SAND, font=f_mono_small)

    # Feature Tag Badges
    badge_y = timer_box_y + 110
    draw.text((title_x, badge_y), "• 15 HANDCRAFTED CHALLENGES", fill=C_CHARCOAL, font=f_mono_small)
    draw.text((title_x, badge_y + 20), "• ZERO CHECKPOINTS  • PURE REFLEX", fill=C_CHARCOAL, font=f_mono_small)
    draw.text((title_x, badge_y + 40), "• PAPER-INDUSTRIAL AESTHETIC", fill=(122, 125, 118), font=f_mono_small)

    # Technical Specs Annotation on top right
    draw.text((width - 240, 26), "FRAME RUNNER // UNIT-01", fill=C_CHARCOAL_MID, font=f_mono_small)
    draw.text((width - 240, 42), "MAX SPEED: 280 PX/S", fill=(122, 125, 118), font=f_mono_small)

    img.convert("RGB").save(out_path, quality=95)
    print(f"Saved: {out_path} ({width}x{height})")

def render_itch_cover(out_path):
    # itch.io standard: 630 x 500
    width = 630
    height = 500
    img = Image.new("RGBA", (width, height), C_PAPER)
    draw = ImageDraw.Draw(img)

    draw_grid_and_technical_marks(draw, width, height, grid_step=28)

    # Platform beneath runner
    plat_x = 240
    plat_y = 390
    plat_w = 360
    plat_h = 36
    draw.rectangle([plat_x, plat_y, plat_x + plat_w, plat_y + plat_h], fill=C_CHARCOAL)
    for tx in range(plat_x + 8, plat_x + plat_w, 16):
        draw.line([(tx, plat_y), (tx, plat_y + 4)], fill=C_SAND, width=1)

    # Bottom Spikes
    draw_spikes_strip(draw, 40, 470, 200, count=8, height=18)

    # Hero Runner (Large, Scale 11.5x)
    draw_hero_runner(img, cx=440, cy=245, scale=11.5, facing=1, lean_deg=10.0)

    # Time Fragment
    draw_time_fragment(img, x=540, y=140, size=20)

    # Left Branding
    f_title = get_font(FONT_BOLD, 58)
    f_sub = get_font(FONT_BOLD, 12)
    f_mono_large = get_font(FONT_MONO, 28)
    f_mono_small = get_font(FONT_MONO, 11)

    title_x = 45
    title_y = 70
    draw.text((title_x, title_y), "CLICK", fill=C_CHARCOAL, font=f_title)

    bar_y = title_y + 66
    draw.rectangle([title_x, bar_y, title_x + 140, bar_y + 5], fill=C_ORANGE)

    draw.text((title_x, bar_y + 14), "10-SECOND TIME-ATTACK", fill=C_CHARCOAL_MID, font=f_sub)

    # Timer Card
    timer_box_x = title_x
    timer_box_y = bar_y + 44
    draw.rectangle([timer_box_x, timer_box_y, timer_box_x + 200, timer_box_y + 70], fill=C_CHARCOAL, outline=C_ORANGE, width=2)
    draw.text((timer_box_x + 12, timer_box_y + 8), "TIME REMAINING", fill=C_SAGE, font=f_mono_small)
    draw.text((timer_box_x + 12, timer_box_y + 26), "09:84", fill=C_ORANGE, font=f_mono_large)

    # Badges
    badge_y = timer_box_y + 90
    draw.text((title_x, badge_y), "15 HANDCRAFTED LEVELS", fill=C_CHARCOAL, font=f_mono_small)
    draw.text((title_x, badge_y + 18), "HIGH-SPEED PLATFORMING", fill=C_CHARCOAL_MID, font=f_mono_small)
    draw.text((title_x, badge_y + 36), "PLAYABLE IN BROWSER", fill=C_ORANGE, font=f_mono_small)

    img.convert("RGB").save(out_path, quality=95)
    print(f"Saved: {out_path} ({width}x{height})")

def render_wide_banner(out_path):
    # Full HD: 1920 x 1080 (Hero Wallpaper / Steam Capsule / Showcase)
    width = 1920
    height = 1080
    img = Image.new("RGBA", (width, height), C_PAPER)
    draw = ImageDraw.Draw(img)

    draw_grid_and_technical_marks(draw, width, height, grid_step=40)

    # Platforms
    plat_x = 980
    plat_y = 820
    plat_w = 840
    plat_h = 60
    draw.rectangle([plat_x, plat_y, plat_x + plat_w, plat_y + plat_h], fill=C_CHARCOAL)
    for tx in range(plat_x + 12, plat_x + plat_w, 24):
        draw.line([(tx, plat_y), (tx, plat_y + 6)], fill=C_SAND, width=2)

    # Left platform
    draw.rectangle([120, 920, 520, 980], fill=C_CHARCOAL)
    # Hazardous spike chasm
    draw_spikes_strip(draw, 540, 1020, 420, count=16, height=36)

    # Hero Runner (Massive scale 26x)
    draw_hero_runner(img, cx=1360, cy=520, scale=26.0, facing=1, lean_deg=11.0)

    # Time Fragment
    draw_time_fragment(img, x=1720, y=340, size=48)

    # Left Section: Typography & Branding
    f_title = get_font(FONT_BOLD, 150)
    f_sub = get_font(FONT_BOLD, 26)
    f_mono_large = get_font(FONT_MONO, 72)
    f_mono_med = get_font(FONT_MONO, 22)
    f_mono_small = get_font(FONT_MONO, 18)

    title_x = 140
    title_y = 160
    draw.text((title_x, title_y), "CLICK", fill=C_CHARCOAL, font=f_title)

    bar_y = title_y + 165
    draw.rectangle([title_x, bar_y, title_x + 360, bar_y + 10], fill=C_ORANGE)

    draw.text((title_x, bar_y + 26), "PRECISION 10-SECOND TIME-ATTACK PLATFORMER", fill=C_CHARCOAL_MID, font=f_sub)

    # 10-Second Digital Timer HUD Card
    timer_box_x = title_x
    timer_box_y = bar_y + 80
    draw.rectangle([timer_box_x, timer_box_y, timer_box_x + 520, timer_box_y + 170], fill=C_CHARCOAL, outline=C_ORANGE, width=3)
    draw.text((timer_box_x + 28, timer_box_y + 20), "COUNTDOWN MATRIX // TIME CRITICAL", fill=C_SAGE, font=f_mono_med)
    draw.text((timer_box_x + 28, timer_box_y + 60), "09:84", fill=C_ORANGE, font=f_mono_large)
    draw.text((timer_box_x + 330, timer_box_y + 90), "SECONDS.FRM", fill=C_SAND, font=f_mono_small)

    # Badges
    badge_y = timer_box_y + 220
    draw.text((title_x, badge_y), "• 15 HANDCRAFTED CHALLENGES", fill=C_CHARCOAL, font=f_mono_med)
    draw.text((title_x, badge_y + 40), "• ZERO CHECKPOINTS  • INSTANT RETRY", fill=C_CHARCOAL, font=f_mono_med)
    draw.text((title_x, badge_y + 80), "• ORIGINAL PAPER-INDUSTRIAL VISUAL IDENTITY", fill=(122, 125, 118), font=f_mono_med)

    # Top right specs
    draw.text((width - 440, 50), "UNIT-01: FRAME RUNNER", fill=C_CHARCOAL_MID, font=f_mono_med)
    draw.text((width - 440, 80), "MAX SPEED: 280 PX/S  |  GL_COMPAT", fill=(122, 125, 118), font=f_mono_small)

    img.convert("RGB").save(out_path, quality=95)
    print(f"Saved: {out_path} ({width}x{height})")

if __name__ == "__main__":
    out_dir = "/Users/raghavsharma/Downloads/CLICk/assets/art"
    os.makedirs(out_dir, exist_ok=True)
    render_playstore_feature_graphic(os.path.join(out_dir, "cover_playstore_1024x500.png"))
    render_itch_cover(os.path.join(out_dir, "cover_itch_630x500.png"))
    render_wide_banner(os.path.join(out_dir, "cover_banner_1920x1080.png"))
