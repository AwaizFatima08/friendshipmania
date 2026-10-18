#!/usr/bin/env python3
"""Builds the friendshipmania launch kit: print poster + Facebook / Instagram /
TikTok images and a TikTok/Reels slideshow video.

    cd marketing/launch && python3 build.py

Needs ImageMagick (convert), Inkscape 1.x and ffmpeg. Art comes from the
approved homidev cutouts in assets/images/, screenshots from graphics/store/,
QR codes from qr/ (see qrgen/ to regenerate them).
"""
import os
import shutil
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
BUILD = os.path.join(HERE, '.build')
OUT = os.path.join(HERE, 'out')

# Brand colours (match the app and the Play feature graphic).
PURPLE, MAGENTA, PINK = '#7C5CF0', '#B84FE0', '#FF5DA2'
LIME, INK, WHITE = '#D6FF3F', '#2B0B4E', '#FFFFFF'
FONT = 'DejaVu Sans'

ART = {
    'mascot': '20261010-1125-friendshipmania-icon-01_cutout.png',
    'ice': '20261010-1125-friendshipmania-icon-02_cutout.png',
    'popcorn': '20261010-1126-friendshipmania-icon-01_cutout.png',
    'flames': '20261010-1127-friendshipmania-icon-01_cutout.png',
    'crown': '20261010-1127-friendshipmania-icon-02_cutout.png',
}


def run(*cmd):
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def prepare_art():
    os.makedirs(BUILD, exist_ok=True)
    for name, file in ART.items():
        run('convert', os.path.join(ROOT, 'assets', 'images', file), '-trim', '+repage',
            os.path.join(BUILD, name + '.png'))


def a(name):
    return os.path.join(BUILD, name + '.png')


def shot(n):
    return os.path.join(ROOT, 'graphics', 'store', f'screenshot_{n}.png')


def qr(channel):
    return os.path.join(HERE, 'qr', f'qr_{channel}.svg')


# ---------------------------------------------------------------- pieces

def defs():
    return f'''<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="{PURPLE}"/><stop offset="0.55" stop-color="{MAGENTA}"/><stop offset="1" stop-color="{PINK}"/>
  </linearGradient>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
    <feGaussianBlur in="SourceAlpha" stdDeviation="16"/>
    <feOffset dy="14" result="blur"/>
    <feFlood flood-color="#2B0B4E" flood-opacity="0.45"/>
    <feComposite in2="blur" operator="in"/>
    <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
  </filter>
</defs>'''


def background(w, h):
    return (f'<rect width="{w}" height="{h}" fill="url(#bg)"/>'
            f'<circle cx="{w * 0.95:.0f}" cy="{h * 0.06:.0f}" r="{w * 0.16:.0f}" fill="{PINK}" fill-opacity="0.45"/>'
            f'<circle cx="{w * 0.03:.0f}" cy="{h * 0.86:.0f}" r="{w * 0.12:.0f}" fill="{LIME}" fill-opacity="0.18"/>')


def sparkle(x, y, s, color=WHITE, opacity=0.9):
    """Four-point sparkle centred on (x, y) with half-size s."""
    k = s * 0.22
    return (f'<path d="M{x} {y - s} Q{x + k} {y - k} {x + s} {y} Q{x + k} {y + k} {x} {y + s} '
            f'Q{x - k} {y + k} {x - s} {y} Q{x - k} {y - k} {x} {y - s}Z" fill="{color}" fill-opacity="{opacity}"/>')


def sticker_text(x, y, text, size, fill=WHITE, anchor='start', length=None, stroke=None):
    """Bold text with a thick dark outline, like a sticker."""
    sw = stroke if stroke is not None else size * 0.16
    fit = f' textLength="{length}" lengthAdjust="spacingAndGlyphs"' if length else ''
    return (f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-family="{FONT}" font-weight="bold" '
            f'font-size="{size}" fill="{fill}" stroke="{INK}" stroke-width="{sw}" stroke-linejoin="round" '
            f'paint-order="stroke"{fit}>{text}</text>')


def plain_text(x, y, text, size, fill=WHITE, anchor='start', weight='bold', opacity=1, length=None):
    fit = f' textLength="{length}" lengthAdjust="spacingAndGlyphs"' if length else ''
    return (f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-family="{FONT}" font-weight="{weight}" '
            f'font-size="{size}" fill="{fill}" fill-opacity="{opacity}"{fit}>{text}</text>')


def pill(x, y, w, h, text, size, fill=LIME, color=INK):
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{h / 2}" fill="{fill}" filter="url(#shadow)"/>'
            + plain_text(x + w / 2, y + h / 2 + size * 0.36, text, size, color, 'middle'))


def image(x, y, w, h, path, extra=''):
    return (f'<image x="{x}" y="{y}" width="{w}" height="{h}" preserveAspectRatio="xMidYMid meet" '
            f'xlink:href="{path}"{extra}/>')


def phone(x, y, w, screenshot, rotate=0, cid='scr'):
    """A simple phone frame (screenshots are 1:2) with a soft shadow."""
    h = w * 2
    pad = w * 0.045
    cx, cy = x + w / 2, y + h / 2
    return f'''<g transform="rotate({rotate} {cx} {cy})" filter="url(#shadow)">
  <clipPath id="{cid}"><rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{w * 0.085}"/></clipPath>
  <rect x="{x - pad}" y="{y - pad}" width="{w + 2 * pad}" height="{h + 2 * pad}" rx="{w * 0.12}" fill="#1B0B33"/>
  <image x="{x}" y="{y}" width="{w}" height="{h}" preserveAspectRatio="xMidYMid slice" clip-path="url(#{cid})" xlink:href="{screenshot}"/>
</g>'''


def mascot_block(cx, cy, r, mw, mh):
    """Mascot standing in front of a lime halo."""
    return (f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{LIME}"/>'
            + image(cx - mw / 2, cy - mh / 2 - r * 0.05, mw, mh, a('mascot'), ' filter="url(#shadow)"'))


def qr_card(x, y, w, h, channel, qsize, lines):
    """White card with the QR code on the left and text lines on the right."""
    pad = (h - qsize) / 2
    with open(qr(channel)) as f:
        code = f.read()  # inline as a nested <svg> so it stays vector-sharp
    code = code.replace('<svg ', f'<svg x="{x + pad}" y="{y + pad}" width="{qsize}" height="{qsize}" ', 1)
    out = [f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{h * 0.14}" fill="{WHITE}" filter="url(#shadow)"/>',
           code]
    tx = x + pad * 2 + qsize
    for dy, text, size, color in lines:
        out.append(plain_text(tx, y + dy, text, size, color))
    return ''.join(out)


def svg(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
            f'width="{w}" height="{h}" viewBox="0 0 {w} {h}">{defs()}{body}</svg>')


# ---------------------------------------------------------------- designs

def poster():
    """A-series portrait (A3/A4 print). 1240 x 1754 units = 1:sqrt(2)."""
    w, h = 1240, 1754
    body = [background(w, h),
            sparkle(1170, 560, 30), sparkle(1205, 625, 14, LIME), sparkle(60, 1330, 22, LIME),
            pill(80, 70, 470, 70, 'NEW APP · OUT NOW', 32),
            sticker_text(80, 290, 'Is your bestie', 124, length=1040),
            sticker_text(80, 425, f'<tspan fill="{LIME}">lying</tspan> to you?', 124),
            plain_text(84, 510, 'Put your friendship on trial: 10 unhinged', 40, opacity=0.95),
            plain_text(84, 562, 'questions, one brutally honest verdict.', 40, opacity=0.95),
            mascot_block(400, 960, 300, 470, 600),
            image(560, 640, 170, 110, a('crown'), ' transform="rotate(12 645 695)"'),
            image(60, 1190, 230, 130, a('flames')),
            phone(800, 650, 330, shot(3), 6, 'p1'),
            image(60, 640, 150, 150, a('ice'), ' transform="rotate(-10 135 715)"'),
            qr_card(70, 1380, 1100, 300, 'poster', 250, [
                (95, 'Scan to take the test', 58, INK),
                (155, 'Free on Google Play', 44, PURPLE),
                (205, 'No ads · About 2 minutes · Ages 13+', 30, '#5B4A7A'),
                (250, 'friendshipmania.homilabs.org', 30, '#5B4A7A'),
            ]),
            plain_text(w / 2, 1730, 'friendshipmania · made by HomiLabs', 28, anchor='middle', opacity=0.85)]
    return w, h, ''.join(body)


def feed(channel):
    """4:5 feed post for Facebook and Instagram."""
    w, h = 1080, 1350
    body = [background(w, h),
            sparkle(990, 300, 24), sparkle(1030, 370, 12, LIME),
            pill(60, 50, 560, 64, 'OUT NOW ON GOOGLE PLAY', 28),
            sticker_text(60, 230, 'Is your bestie', 106, length=900),
            sticker_text(60, 345, f'<tspan fill="{LIME}">lying</tspan> to you?', 106),
            plain_text(64, 415, '10 unhinged questions. 1 brutal verdict.', 36, opacity=0.95),
            mascot_block(310, 750, 250, 400, 510),
            image(440, 470, 140, 95, a('crown'), ' transform="rotate(12 510 517)"'),
            phone(660, 470, 300, shot(3), 6, 'p1'),
            qr_card(50, 1090, 980, 220, channel, 180, [
                (78, 'Scan to put your bestie on trial', 38, INK),
                (128, 'Free on Google Play · No ads', 30, PURPLE),
                (172, 'Search “friendshipmania” · Ages 13+', 26, '#5B4A7A'),
            ])]
    return w, h, ''.join(body)


def story(channel):
    """9:16 story / TikTok photo. Keeps clear of the top 220 px and the bottom
    400 px where Instagram and TikTok draw their own UI."""
    w, h = 1080, 1920
    body = [background(w, h),
            sparkle(960, 300, 26), sparkle(1010, 380, 13, LIME), sparkle(110, 1640, 30, LIME),
            pill(60, 230, 560, 64, 'OUT NOW ON GOOGLE PLAY', 28),
            sticker_text(60, 420, 'Is your bestie', 108, length=920),
            sticker_text(60, 540, f'<tspan fill="{LIME}">lying</tspan> to you?', 108),
            plain_text(64, 612, '10 unhinged questions. 1 brutal verdict.', 36, opacity=0.95),
            mascot_block(300, 900, 230, 370, 470),
            image(420, 650, 130, 88, a('crown'), ' transform="rotate(12 485 694)"'),
            phone(655, 655, 265, shot(3), 6, 'p1'),
            qr_card(50, 1250, 900, 270, channel, 230, [
                (95, 'Scan to play free', 40, INK),
                (145, 'on Google Play', 32, PURPLE),
                (195, 'No ads · Ages 13+', 26, '#5B4A7A'),
                (235, 'Link in bio', 26, '#5B4A7A'),
            ]),
            image(780, 1560, 220, 120, a('flames'))]
    return w, h, ''.join(body)


def video_hook():
    w, h = 1080, 1920
    body = [background(w, h), sparkle(950, 330, 28), sparkle(1000, 410, 14, LIME),
            sticker_text(70, 470, 'POV: you ask', 112, length=900),
            sticker_text(70, 600, 'the polygraph', 112, length=900),
            sticker_text(70, 730, f'about your <tspan fill="{LIME}">bestie</tspan>', 104, length=920),
            mascot_block(540, 1180, 300, 470, 600),
            image(130, 1440, 230, 130, a('flames'))]
    return w, h, ''.join(body)


def video_step(n, line1, line2, screenshot):
    w, h = 1080, 1920
    body = [background(w, h), sparkle(980, 260, 22), sparkle(90, 1650, 26, LIME),
            pill(60, 230, 150, 70, f'{n}/4', 36),
            sticker_text(60, 410, line1, 74),
            sticker_text(60, 500, line2, 74),
            phone(290, 600, 500, screenshot, 0, f'p{n}')]
    return w, h, ''.join(body)


# ---------------------------------------------------------------- export

def export(name, design, pdf=False, width=None):
    w, h, body = design
    src = os.path.join(BUILD, name + '.svg')
    with open(src, 'w') as f:
        f.write(svg(w, h, body))
    png = os.path.join(OUT, name + '.png')
    run('inkscape', src, '--export-type=png', f'--export-filename={png}', '-w', str(width or w))
    # Flatten (no alpha) so every platform shows the colours as designed.
    run('convert', png, '-background', PURPLE, '-alpha', 'remove', '-alpha', 'off', png)
    if pdf:
        run('inkscape', src, '--export-type=pdf', f'--export-filename={os.path.join(OUT, name + ".pdf")}',
            '--export-text-to-path')
    return png


def video(frames, out):
    """Crossfaded slideshow with a silent track (add a trending sound in-app)."""
    durations = [2.6, 2.2, 2.2, 2.2, 2.2, 4.5]
    fade = 0.4
    cmd = ['ffmpeg', '-y']
    for f, d in zip(frames, durations):
        cmd += ['-loop', '1', '-t', str(d), '-framerate', '30', '-i', f]
    cmd += ['-f', 'lavfi', '-t', str(sum(durations) - fade * (len(frames) - 1)), '-i',
            'anullsrc=channel_layout=stereo:sample_rate=44100']
    chains, prev, offset = [], '0:v', 0.0
    for i in range(1, len(frames)):
        offset += durations[i - 1] - fade
        chains.append(f'[{prev}][{i}:v]xfade=transition=slideleft:duration={fade}:offset={offset:.2f}[v{i}]')
        prev = f'v{i}'
    chains.append(f'[{prev}]format=yuv420p[vout]')
    cmd += ['-filter_complex', ';'.join(chains), '-map', '[vout]', '-map', f'{len(frames)}:a',
            '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-c:a', 'aac', '-shortest',
            '-movflags', '+faststart', out]
    run(*cmd)


def main():
    prepare_art()
    os.makedirs(OUT, exist_ok=True)
    export('poster_A3', poster(), pdf=True, width=3508)  # 300 dpi at A3; scales down for A4
    export('facebook_post_1080x1350', feed('facebook'))
    export('instagram_post_1080x1350', feed('instagram'))
    export('instagram_story_1080x1920', story('instagram'))
    export('tiktok_photo_1080x1920', story('tiktok'))
    frames = [export('_video_0_hook', video_hook())]
    steps = [('Start the', 'interrogation', 1), ('Answer 10 unhinged', 'questions', 2),
             ('Get the brutal', 'verdict', 3), ('Send it.', 'Start the drama.', 4)]
    for n, (l1, l2, s) in enumerate(steps, 1):
        frames.append(export(f'_video_{n}_step', video_step(n, l1, l2, shot(s))))
    frames.append(os.path.join(OUT, 'tiktok_photo_1080x1920.png'))
    video(frames, os.path.join(OUT, 'tiktok_reels_video_1080x1920.mp4'))
    for f in os.listdir(OUT):
        if f.startswith('_video_'):
            shutil.move(os.path.join(OUT, f), os.path.join(BUILD, f))
    print('built:', ', '.join(sorted(os.listdir(OUT))))


if __name__ == '__main__':
    main()
