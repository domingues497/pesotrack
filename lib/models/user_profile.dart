enum BiologicalSex { male, female }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.initialWeight,
    required this.heightCm,
    required this.sex,
    required this.birthDate,
    required this.goalWeight,
  });

  final String name;
  final double initialWeight;
  final double heightCm;
  final BiologicalSex sex;
  final DateTime birthDate;
  final double goalWeight;

  int get age {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final birthdayPassed = now.month > birthDate.month || (now.month == birthDate.month && now.day >= birthDate.day);
    if (!birthdayPassed) {
      years -= 1;
    }
    return years;
  }
}
