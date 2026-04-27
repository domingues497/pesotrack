import '../models/imc_result.dart';
import '../models/user_profile.dart';

abstract final class ImcCalculator {
  static ImcResult calculate({
    required double weightKg,
    required double heightCm,
    required BiologicalSex sex,
    required int age,
  }) {
    final heightM = heightCm / 100;
    final value = weightKg / (heightM * heightM);
    final base = heightCm - 100;
    final idealMin = sex == BiologicalSex.female ? base * 0.85 : base * 0.90;
    final idealMax = sex == BiologicalSex.female ? base : base * 1.05;

    return ImcResult(
      value: value,
      classification: _classificationFor(value),
      idealWeightMin: idealMin,
      idealWeightMax: idealMax,
      seniorWarning: age >= 65,
    );
  }

  static String _classificationFor(double value) {
    if (value < 18.5) return 'Abaixo do peso';
    if (value < 25) return 'Peso normal';
    if (value < 30) return 'Sobrepeso';
    if (value < 35) return 'Obesidade grau I';
    if (value < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }
}
