class ImcResult {
  const ImcResult({
    required this.value,
    required this.classification,
    required this.idealWeightMin,
    required this.idealWeightMax,
    required this.seniorWarning,
  });

  final double value;
  final String classification;
  final double idealWeightMin;
  final double idealWeightMax;
  final bool seniorWarning;
}
