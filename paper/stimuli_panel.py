"""The stimulus panel of Figure 1: one row per illusion, three columns (the
strongest facilitating context, the weakest context of the same difficulty
set, the strongest conflicting context), at one moderate objective
difference, from the task's own images.

The images are those the experiment loaded from
https://realitybending.github.io/IllusionGame/v3/stimuli/; the local copy is
the IllusionGame repository. Run from the repo root:

    python paper/stimuli_panel.py            # -> paper/figures/stimuli.png

The task's design is a checkerboard, so the three strengths shown share one
difference set; the script picks them. Each image is cropped to its content.
"""
import os, re, sys
from PIL import Image, ImageDraw, ImageFont, ImageOps

src = os.environ.get("IGSA_STIMULI", os.path.expanduser("~/Dropbox/Software/IllusionGame/v3/stimuli"))
out = sys.argv[1] if len(sys.argv) > 1 else "paper/figures/stimuli.png"
os.makedirs(os.path.dirname(out), exist_ok=True)
illusions = [("Ebbinghaus", "Ebbinghaus"), ("MullerLyer", "Müller-Lyer"), ("VerticalHorizontal", "Vertical-horizontal")]

table = {}
for f in os.listdir(src):
    m = re.match(r"^(\w+)_(-?[0-9.]+)_(-?[0-9.]+)\.png$", f)
    if m:
        table.setdefault(m.group(1), {}).setdefault(float(m.group(2)), {})[float(m.group(3))] = f

chosen = {}
for key, label in illusions:
    by_strength = table[key]
    smax = max(by_strength)
    def diffs(s): return {d for d in by_strength[s] if 0 < d < 1}  # the design's range, not the practice extremes
    common_hi = diffs(smax) & diffs(-smax)
    weak = min(s for s in by_strength if s > 0 and diffs(s) & common_hi)
    common = sorted(common_hi & diffs(weak))
    d = common[len(common) // 2 + 1] if len(common) > 2 else common[-1]
    chosen[key] = [(s, by_strength[s][d]) for s in (-smax, weak, smax)]
    print(label, "difference", d, "strengths", [s for s, _ in chosen[key]])

def load(f):
    im = Image.open(os.path.join(src, f)).convert("RGBA")
    return Image.alpha_composite(Image.new("RGBA", im.size, "white"), im).convert("RGB")

cell_w, cell_hmax, pad, left, header, margin = 440, 300, 18, 270, 56, 24
rows = []
for key, label in illusions:
    ims = [load(f) for _, f in chosen[key]]
    # One crop box per row, the union of the three images' content, so that
    # the targets keep their size and position across the columns.
    boxes = [ImageOps.invert(im).getbbox() for im in ims]
    x0 = max(0, min(b[0] for b in boxes) - margin)
    y0 = max(0, min(b[1] for b in boxes) - margin)
    x1 = min(ims[0].width, max(b[2] for b in boxes) + margin)
    y1 = min(ims[0].height, max(b[3] for b in boxes) + margin)
    crops = [im.crop((x0, y0, x1, y1)) for im in ims]
    s = min(cell_w / (x1 - x0), cell_hmax / (y1 - y0))
    scaled = [c.resize((int(c.width * s), int(c.height * s)), Image.LANCZOS) for c in crops]
    rows.append((label, scaled, max(im.height for im in scaled) + 24))

W = left + 3 * cell_w + 2 * pad
H = header + sum(h for _, _, h in rows) + 2 * pad
canvas = Image.new("RGB", (W, H), "white")
draw = ImageDraw.Draw(canvas)
try:
    bold = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 30)
except OSError:
    bold = ImageFont.load_default()
cols = ["Facilitating (strength -1)", "Weakest context", "Conflicting (strength +1)"]
for j, c in enumerate(cols):
    x = left + j * (cell_w + pad) + cell_w / 2
    draw.text((x - draw.textlength(c, font=bold) / 2, 14), c, fill="black", font=bold)
y = header
for i, (label, ims, h) in enumerate(rows):
    draw.text((10, y + h / 2 - 16), label, fill="black", font=bold)
    for j, im in enumerate(ims):
        x = left + j * (cell_w + pad) + (cell_w - im.width) // 2
        canvas.paste(im, (x, y + (h - im.height) // 2))
    y += h + pad
canvas.save(out, dpi=(300, 300))
print("saved", out, canvas.size)
