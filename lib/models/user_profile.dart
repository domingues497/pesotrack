enum GoalStrategy { suggestedByImc, custom }

enum BiologicalSex { male, female }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.initialWeight,
    required this.heightCm,
    required this.sex,
    required this.birthDate,
    required this.goalWeight,
    required this.goalStrategy,
  });

  final String name;
  final double initialWeight;
  final double heightCm;
  final BiologicalSex sex;
  final DateTime birthDate;
  final double goalWeight;
  final GoalStrategy goalStrategy;

  int get age {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final birthdayPassed = now.month > birthDate.month || (now.month == birthDate.month && now.day >= birthDate.day);
    if (!birthdayPassed) {
      years -= 1;
    }
    return years;
  }

  String get sexLabel => sex == BiologicalSex.female ? 'Feminino' : 'Masculino';

  String get goalStrategyLabel => switch (goalStrategy) {
        GoalStrategy.suggestedByImc => 'Meta sugerida pelo IMC',
        GoalStrategy.custom => 'Meta personalizada',
      };

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'initialWeight': initialWeight,
      'heightCm': heightCm,
      'sex': sex.name,
      'birthDate': birthDate.toIso8601String(),
      'goalWeight': goalWeight,
      'goalStrategy': goalStrategy.name,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      initialWeight: (json['initialWeight'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      sex: BiologicalSex.values.firstWhere(
        (value) => value.name == json['sex'],
        orElse: () => BiologicalSex.male,
      ),
      birthDate: DateTime.parse(json['birthDate'] as String),
      goalWeight: (json['goalWeight'] as num).toDouble(),
      goalStrategy: GoalStrategy.values.firstWhere(
        (value) => value.name == json['goalStrategy'],
        orElse: () => GoalStrategy.custom,
      ),
    );
  }
}
