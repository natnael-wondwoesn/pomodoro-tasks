from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]

IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

ANDROID_ICONS = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def lerp(a: int, b: int, t: float) -> int:
    return round(a + (b - a) * t)


def radial_gradient(size: int, center: tuple[float, float], inner: tuple[int, int, int], outer: tuple[int, int, int]) -> Image.Image:
    image = Image.new("RGBA", (size, size))
    pixels = image.load()
    cx, cy = center
    max_distance = math.hypot(max(cx, size - cx), max(cy, size - cy))
    for y in range(size):
        for x in range(size):
            t = min(1.0, math.hypot(x - cx, y - cy) / max_distance)
            pixels[x, y] = (
                lerp(inner[0], outer[0], t),
                lerp(inner[1], outer[1], t),
                lerp(inner[2], outer[2], t),
                255,
            )
    return image


def rounded_rect_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def heart_points(size: int) -> list[tuple[float, float]]:
    points: list[tuple[float, float]] = []
    scale = size * 0.023
    cx = size / 2
    cy = size * 0.51
    for i in range(360):
        t = math.radians(i)
        x = 16 * math.sin(t) ** 3
        y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        points.append((cx + x * scale, cy - y * scale))
    return points


def make_master(size: int = 1024) -> Image.Image:
    background = radial_gradient(
        size,
        (size * 0.34, size * 0.24),
        (255, 244, 230),
        (241, 214, 183),
    ).convert("RGBA")
    background.putalpha(rounded_rect_mask(size, round(size * 0.22)))

    heart_mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(heart_mask).polygon(heart_points(size), fill=255)

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_mask = heart_mask.filter(ImageFilter.GaussianBlur(size * 0.025))
    shadow.putalpha(shadow_mask.point(lambda px: int(px * 0.23)))
    background.alpha_composite(shadow, (0, round(size * 0.035)))

    tomato = radial_gradient(
        size,
        (size * 0.35, size * 0.30),
        (229, 169, 124),
        (189, 111, 75),
    )
    tomato.putalpha(heart_mask)
    background.alpha_composite(tomato)

    draw = ImageDraw.Draw(background)
    line_color = (96, 60, 39, 38)
    for offset in (-0.18, 0.18):
        x = size * (0.5 + offset)
        draw.arc(
            (x - size * 0.16, size * 0.25, x + size * 0.16, size * 0.78),
            start=82,
            end=278,
            fill=line_color,
            width=max(2, round(size * 0.012)),
        )

    highlight = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_draw.ellipse(
        (
            size * 0.28,
            size * 0.29,
            size * 0.49,
            size * 0.50,
        ),
        fill=(255, 255, 255, 64),
    )
    highlight = highlight.filter(ImageFilter.GaussianBlur(size * 0.018))
    background.alpha_composite(highlight)

    green = (123, 158, 107, 255)
    dark_green = (96, 132, 83, 255)
    stem_width = max(5, round(size * 0.035))
    draw.line(
        [(size * 0.47, size * 0.27), (size * 0.43, size * 0.17)],
        fill=dark_green,
        width=stem_width,
        joint="curve",
    )
    draw.line(
        [(size * 0.53, size * 0.27), (size * 0.58, size * 0.17)],
        fill=green,
        width=stem_width,
        joint="curve",
    )
    draw.ellipse((size * 0.31, size * 0.13, size * 0.49, size * 0.25), fill=green)
    draw.ellipse((size * 0.51, size * 0.13, size * 0.69, size * 0.25), fill=dark_green)

    clock_center = (size * 0.61, size * 0.48)
    clock_radius = size * 0.095
    clock_box = (
        clock_center[0] - clock_radius,
        clock_center[1] - clock_radius,
        clock_center[0] + clock_radius,
        clock_center[1] + clock_radius,
    )
    draw.arc(clock_box, start=-90, end=260, fill=(255, 255, 255, 128), width=max(3, round(size * 0.018)))
    draw.line(
        [clock_center, (clock_center[0] + size * 0.012, clock_center[1] - size * 0.065)],
        fill=(255, 255, 255, 150),
        width=max(3, round(size * 0.014)),
    )
    draw.line(
        [clock_center, (clock_center[0] + size * 0.06, clock_center[1] + size * 0.018)],
        fill=(255, 255, 255, 130),
        width=max(3, round(size * 0.014)),
    )
    draw.ellipse(
        (
            clock_center[0] - size * 0.014,
            clock_center[1] - size * 0.014,
            clock_center[0] + size * 0.014,
            clock_center[1] + size * 0.014,
        ),
        fill=(255, 255, 255, 180),
    )

    return background.convert("RGB")


def save_icon(master: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    icon = master.resize((size, size), Image.Resampling.LANCZOS)
    icon.save(path, "PNG", optimize=True)


def main() -> None:
    master = make_master()
    ios_dir = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for filename, size in IOS_ICONS.items():
        save_icon(master, ios_dir / filename, size)

    android_res = ROOT / "android" / "app" / "src" / "main" / "res"
    for density, size in ANDROID_ICONS.items():
        save_icon(master, android_res / density / "ic_launcher.png", size)

    preview = ROOT / "assets" / "generated" / "app_icon_preview.png"
    save_icon(master, preview, 512)
    print(f"Generated app icons from heart-tomato logo. Preview: {preview}")


if __name__ == "__main__":
    main()
