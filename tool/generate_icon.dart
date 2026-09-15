// Procedurally draws the DocuScan launcher icon (brand gradient + document/scan glyph)
// so the app ships with a real icon instead of the flutter-create placeholder.
// Run: dart run tool/generate_icon.dart
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void _thickLine(img.Image image, double x1, double y1, double x2, double y2, double thickness, img.Color color) {
  final dx = x2 - x1, dy = y2 - y1;
  final len = sqrt(dx * dx + dy * dy);
  final ux = -dy / len, uy = dx / len;
  final hw = thickness / 2;
  img.fillPolygon(image, color: color, vertices: [
    img.Point(x1 + ux * hw, y1 + uy * hw),
    img.Point(x2 + ux * hw, y2 + uy * hw),
    img.Point(x2 - ux * hw, y2 - uy * hw),
    img.Point(x1 - ux * hw, y1 - uy * hw),
  ]);
  img.fillCircle(image, x: x1.round(), y: y1.round(), radius: hw.round(), color: color, antialias: true);
  img.fillCircle(image, x: x2.round(), y: y2.round(), radius: hw.round(), color: color, antialias: true);
}

const ink = 0xFF152038;
const primary = 0xFF4F6BFF;
const mint = 0xFF18B88B;

img.Color _lerpColor(int c1, int c2, double t) {
  final r1 = (c1 >> 16) & 0xFF, g1 = (c1 >> 8) & 0xFF, b1 = c1 & 0xFF;
  final r2 = (c2 >> 16) & 0xFF, g2 = (c2 >> 8) & 0xFF, b2 = c2 & 0xFF;
  return img.ColorRgb8(
    (r1 + (r2 - r1) * t).round(),
    (g1 + (g2 - g1) * t).round(),
    (b1 + (b2 - b1) * t).round(),
  );
}

bool _inRoundedRect(double x, double y, double left, double top, double right, double bottom, double r) {
  if (x < left || x > right || y < top || y > bottom) return false;
  if (x >= left + r && x <= right - r) return true;
  if (y >= top + r && y <= bottom - r) return true;
  final cx = x < left + r ? left + r : right - r;
  final cy = y < top + r ? top + r : bottom - r;
  final dx = x - cx, dy = y - cy;
  return dx * dx + dy * dy <= r * r;
}

void _paintGradient(img.Image image, {required bool rounded}) {
  final w = image.width, h = image.height;
  const radius = 220.0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final inside = rounded ? _inRoundedRect(x.toDouble(), y.toDouble(), 0, 0, (w - 1).toDouble(), (h - 1).toDouble(), radius) : true;
      if (!inside) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }
      final t = ((x + y) / (w + h)).clamp(0.0, 1.0);
      final c = _lerpColor(ink, primary, t);
      image.setPixelRgba(x, y, c.r, c.g, c.b, 255);
    }
  }
}

void _drawGlyph(img.Image image, {required double cx, required double cy, required double scale}) {
  final docW = 340 * scale, docH = 460 * scale, fold = 70 * scale;
  final left = cx - docW / 2, top = cy - docH / 2 - 20 * scale;
  final right = left + docW, bottom = top + docH;

  img.fillPolygon(image, color: img.ColorRgb8(0xFF, 0xFF, 0xFF), vertices: [
    img.Point(left, top),
    img.Point(right - fold, top),
    img.Point(right, top + fold),
    img.Point(right, bottom),
    img.Point(left, bottom),
  ]);
  img.fillPolygon(image, color: img.ColorRgb8(0xC9, 0xD3, 0xF7), vertices: [
    img.Point(right - fold, top),
    img.Point(right, top + fold),
    img.Point(right - fold, top + fold),
  ]);

  final lineColor = img.ColorRgb8(0xB9, 0xC4, 0xFF);
  final lineLeft = left + 50 * scale;
  final lineThickness = (20 * scale).round();
  final widths = [240.0, 240.0, 240.0, 160.0];
  for (var i = 0; i < widths.length; i++) {
    final ly = (top + 130 * scale + i * 56 * scale).round();
    img.fillRect(image,
        x1: lineLeft.round(), y1: ly, x2: (lineLeft + widths[i] * scale).round(), y2: ly + lineThickness, color: lineColor);
  }

  final badgeR = (100 * scale).round();
  final badgeX = right.round(), badgeY = bottom.round();
  img.fillCircle(image, x: badgeX, y: badgeY, radius: badgeR + (14 * scale).round(), color: img.ColorRgb8(0xFF, 0xFF, 0xFF), antialias: true);
  img.fillCircle(image, x: badgeX, y: badgeY, radius: badgeR, color: img.ColorRgb8((mint >> 16) & 0xFF, (mint >> 8) & 0xFF, mint & 0xFF), antialias: true);
  final check = img.ColorRgb8(0xFF, 0xFF, 0xFF);
  final t = (16 * scale).clamp(6, 100).toDouble();
  final ax = badgeX - 46 * scale, ay = badgeY.toDouble();
  final bx = badgeX - 14 * scale, by = badgeY + 32 * scale;
  final cx2 = badgeX + 50 * scale, cy2 = badgeY - 40 * scale;
  _thickLine(image, ax, ay, bx, by, t, check);
  _thickLine(image, bx, by, cx2, cy2, t, check);
}

void main() {
  final full = img.Image(width: 1024, height: 1024, numChannels: 4);
  _paintGradient(full, rounded: true);
  _drawGlyph(full, cx: 512, cy: 500, scale: 1.0);
  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(full));

  final background = img.Image(width: 1024, height: 1024, numChannels: 4);
  _paintGradient(background, rounded: false);
  File('assets/icon/icon_background.png').writeAsBytesSync(img.encodePng(background));

  // The document+badge cluster's visual bbox isn't centered on (cx,cy) because the
  // badge bulges past the document's bottom-right corner; shift the draw origin so
  // the combined glyph is centered in the adaptive icon's safe zone.
  final foreground = img.Image(width: 1024, height: 1024, numChannels: 4);
  _drawGlyph(foreground, cx: 474, cy: 488, scale: 0.66);
  File('assets/icon/icon_foreground.png').writeAsBytesSync(img.encodePng(foreground));

  stdout.writeln('Wrote assets/icon/icon.png, icon_background.png, icon_foreground.png');
}
