import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  OcrService() : _textRecognizer = TextRecognizer();

  final TextRecognizer _textRecognizer;

  Future<double?> extractWeightFromFile(String filePath) async {
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
