"""Generate the NutriFlow launcher icon from the design system tokens.

The icon is a solid "N" monogram in Plus Jakarta Sans on the app's warm
off-white background, using the single accent green defined in CLAUDE.md
section 5. Nothing here is eyeballed: both colours are the HSL tokens
converted verbatim.

Run it from the project root with the variable Plus Jakarta Sans TTF:

    python tool/generate_app_icon.py path/to/PlusJakartaSans[wght].ttf

It writes three masters to assets/icon/, which flutter_launcher_icons then
resizes into every Android density, the iOS appiconset and the Windows .ico:

  app_icon.png             full-bleed square, for iOS and legacy launchers
  app_icon_foreground.png  transparent, inset for the adaptive-icon safe zone
  app_icon_monochrome.png  the same glyph in black, for Android 13 themed icons
"""

from __future__ import annotations

import colorsys
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

SIZE = 1024

# CLAUDE.md section 5, light palette.
BACKGROUND_HSL = (40, 30, 99)  # --background
PRIMARY_HSL = (95, 30, 42)  # --primary, the app's only accent

# Share of the canvas the glyph's cap height occupies.
#
# The same value is used for the adaptive-icon layers on purpose: an adaptive
# icon is masked by the launcher and only its middle region is guaranteed
# visible, but flutter_launcher_icons already insets the foreground by 16% when
# it writes mipmap-anydpi-v26/ic_launcher.xml. Insetting here as well would
# apply the safe zone twice and leave the glyph noticeably undersized.
GLYPH_HEIGHT_FRACTION = 0.52


def hsl_to_rgb(hue: float, saturation: float, lightness: float) -> tuple[int, int, int]:
    """Convert a CSS-style hsl() triple to 8-bit RGB."""
    red, green, blue = colorsys.hls_to_rgb(hue / 360, lightness / 100, saturation / 100)
    return round(red * 255), round(green * 255), round(blue * 255)


def load_font(font_path: Path, pixel_size: int) -> ImageFont.FreeTypeFont:
    """Load Plus Jakarta Sans at its Bold instance when the file is variable."""
    font = ImageFont.truetype(str(font_path), pixel_size)
    try:
        font.set_variation_by_name("Bold")
    except OSError:
        # A static Bold TTF has no named instances; it is already the right
        # weight, so there is nothing to select.
        pass
    return font


def render_glyph(colour: tuple[int, int, int, int], height_fraction: float) -> Image.Image:
    """Draw a centred "N" on a transparent square canvas.

    The glyph is rendered oversized, trimmed to its own ink bounds, and then
    scaled to the requested fraction of the canvas. Measuring the actual ink
    rather than the font metrics is what makes the result optically centred:
    line height and side bearings would otherwise push it off-centre.
    """
    font = load_font(FONT_PATH, SIZE)
    oversized = Image.new("RGBA", (SIZE * 2, SIZE * 2), (0, 0, 0, 0))
    ImageDraw.Draw(oversized).text((SIZE, SIZE), "N", font=font, fill=colour, anchor="mm")

    ink = oversized.crop(oversized.getbbox())
    target_height = round(SIZE * height_fraction)
    target_width = round(ink.width * target_height / ink.height)
    ink = ink.resize((target_width, target_height), Image.LANCZOS)

    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    canvas.paste(ink, ((SIZE - target_width) // 2, (SIZE - target_height) // 2), ink)
    return canvas


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2

    global FONT_PATH
    FONT_PATH = Path(sys.argv[1])
    if not FONT_PATH.is_file():
        print(f"Font not found: {FONT_PATH}")
        return 1

    background = hsl_to_rgb(*BACKGROUND_HSL)
    primary = hsl_to_rgb(*PRIMARY_HSL) + (255,)

    out_dir = Path("assets/icon")
    out_dir.mkdir(parents=True, exist_ok=True)

    full_bleed = Image.new("RGBA", (SIZE, SIZE), background + (255,))
    glyph = render_glyph(primary, GLYPH_HEIGHT_FRACTION)
    full_bleed.alpha_composite(glyph)
    full_bleed.convert("RGB").save(out_dir / "app_icon.png")

    render_glyph(primary, GLYPH_HEIGHT_FRACTION).save(out_dir / "app_icon_foreground.png")
    render_glyph((0, 0, 0, 255), GLYPH_HEIGHT_FRACTION).save(
        out_dir / "app_icon_monochrome.png"
    )

    print(f"background {background}, primary {primary[:3]} -> {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
