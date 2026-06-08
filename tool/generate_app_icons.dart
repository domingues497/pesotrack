import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final sourceFile = File('PesoTrack.png');
  if (!sourceFile.existsSync()) {
    stderr.writeln('Arquivo PesoTrack.png nao encontrado na raiz do projeto.');
    exitCode = 1;
    return;
  }

  final sourceBytes = sourceFile.readAsBytesSync();
  final sourceImage = img.decodeImage(sourceBytes);
  if (sourceImage == null) {
    stderr.writeln('Nao foi possivel ler PesoTrack.png.');
    exitCode = 1;
    return;
  }

  final cropBounds = _findVisibleBounds(sourceImage, alphaThreshold: 20);
  final cropped = img.copyCrop(
    sourceImage,
    x: cropBounds.$1,
    y: cropBounds.$2,
    width: cropBounds.$3,
    height: cropBounds.$4,
  );

  const canvasSize = 1024;
  const visualFill = 0.88;
  final targetSide = (canvasSize * visualFill).round();
  final foreground = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  final background = _buildBackground(canvasSize);
  final composite = _buildBackground(canvasSize);

  final resized = _resizeToFit(cropped, targetSide);
  final dx = ((canvasSize - resized.width) / 2).round();
  final dy = ((canvasSize - resized.height) / 2).round();

  img.compositeImage(foreground, resized, dstX: dx, dstY: dy);
  img.compositeImage(composite, resized, dstX: dx, dstY: dy);

  final iconsDir = Directory('assets/icons')..createSync(recursive: true);
  File('${iconsDir.path}/foreground.png').writeAsBytesSync(img.encodePng(foreground));
  File('${iconsDir.path}/background.png').writeAsBytesSync(img.encodePng(background));
  File('${iconsDir.path}/launcher_base.png').writeAsBytesSync(img.encodePng(composite));

  final playStore = img.copyResize(composite, width: 512, height: 512, interpolation: img.Interpolation.cubic);
  File('${iconsDir.path}/play_store_512.png').writeAsBytesSync(img.encodePng(playStore));

  stdout.writeln('Arquivos gerados em ${iconsDir.path}');
}

(int, int, int, int) _findVisibleBounds(img.Image image, {required int alphaThreshold}) {
  var minX = image.width;
  var minY = image.height;
  var maxX = -1;
  var maxY = -1;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.a < alphaThreshold) {
        continue;
      }
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }

  if (maxX == -1 || maxY == -1) {
    return (0, 0, image.width, image.height);
  }

  const padding = 8;
  minX = (minX - padding).clamp(0, image.width - 1);
  minY = (minY - padding).clamp(0, image.height - 1);
  maxX = (maxX + padding).clamp(0, image.width - 1);
  maxY = (maxY + padding).clamp(0, image.height - 1);

  return (minX, minY, maxX - minX + 1, maxY - minY + 1);
}

img.Image _resizeToFit(img.Image image, int targetSide) {
  if (image.width >= image.height) {
    return img.copyResize(image, width: targetSide, interpolation: img.Interpolation.cubic);
  }
  return img.copyResize(image, height: targetSide, interpolation: img.Interpolation.cubic);
}

img.Image _buildBackground(int size) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  for (var y = 0; y < size; y++) {
    final t = y / (size - 1);
    final r = _lerp(4, 15, t);
    final g = _lerp(27, 58, t);
    final b = _lerp(48, 82, t);
    final color = img.ColorRgb8(r, g, b);
    img.fillRect(image, x1: 0, y1: y, x2: size - 1, y2: y, color: color);
  }
  return image;
}

int _lerp(int start, int end, double t) {
  return (start + (end - start) * t).round();
}
