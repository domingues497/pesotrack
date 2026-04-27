abstract final class WeightValidator {
  static String? validate(double? value) {
    if (value == null) return 'Informe um peso.';
    if (value < 20 || value > 300) return 'Use um valor entre 20 e 300 kg.';
    final parts = value.toString().split('.');
    if (parts.length > 1 && parts[1].length > 1) return 'Use no maximo uma casa decimal.';
    return null;
  }
}
