import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  OcrService() : _textRecognizer = TextRecognizer();

  final TextRecognizer _textRecognizer;

  Future<double?> extractWeightFromFile(String filePath) async {
    final croppedPath = await _createCenteredCrop(filePath);
    final croppedCandidate = await _extractBestCandidate(croppedPath);
    if (croppedCandidate != null) {
      return croppedCandidate;
    }

    return _extractBestCandidate(filePath);
  }

  Future<double?> _extractBestCandidate(String filePath) async {
    try {
      final image = InputImage.fromFilePath(filePath);
      final result = await _textRecognizer.processImage(image);

      double? bestCandidate;
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final candidate = _parseBestWeight(line.text);
          if (candidate == null) {
            continue;
          }
          if (bestCandidate == null || candidate > bestCandidate) {
            bestCandidate = candidate;
          }
        }
      }
      return bestCandidate;
    } catch (_) {
      return null;
    }
  }

  Future<String> _createCenteredCrop(String filePath) async {
    final originalFile = File(filePath);
    final bytes = await originalFile.readAsBytes();
    final sourceImage = img.decodeImage(bytes);
    if (sourceImage == null) {
      return filePath;
    }

    final cropWidth = (sourceImage.width * 0.72).round().clamp(1, sourceImage.width);
    final cropHeight = (sourceImage.height * 0.28).round().clamp(1, sourceImage.height);
    final x = ((sourceImage.width - cropWidth) / 2).round().clamp(0, sourceImage.width - cropWidth);
    final y = ((sourceImage.height - cropHeight) / 2).round().clamp(0, sourceImage.height - cropHeight);
    final cropped = img.copyCrop(
      sourceImage,
      x: x,
      y: y,
      width: cropWidth,
      height: cropHeight,
    );

    final croppedPath = '$filePath.crop.jpg';
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));
    return croppedPath;
  }

  Future<void> deleteTempCrop(String filePath) async {
    final croppedFile = File('$filePath.crop.jpg');
    if (await croppedFile.exists()) {
      await croppedFile.delete();
    }
  }

  bool isStableReading(List<double> recentReadings) {
    if (recentReadings.length < 3) {
      return false;
    }

    final recent = recentReadings.sublist(recentReadings.length - 3);
    final rounded = recent.map((value) => value.toStringAsFixed(1)).toSet();
    if (rounded.length == 1) {
      return true;
    }

    final maxValue = recent.reduce((a, b) => a > b ? a : b);
    final minValue = recent.reduce((a, b) => a < b ? a : b);
    return (maxValue - minValue) <= 0.2;
  }

  double? _parseBestWeight(String rawText) {
    final normalized = rawText.replaceAll(',', '.');
    final matches = RegExp(r'\d{2,3}(?:\.\d)?').allMatches(normalized);

    double? best;
    for (final match in matches) {
      final value = double.tryParse(match.group(0)!);
      if (value == null || value < 20 || value > 300) {
        continue;
      }
      if (best == null || value > best) {
        best = value;
      }
    }
    return best;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
