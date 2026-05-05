enum GoalStrategy { suggestedByImc, custom }

enum BiologicalSex { male, female }

enum GoalStatus { active, completed, cancelled }

class GoalPlan {
  const GoalPlan({
    required this.id,
    required this.startWeight,
    required this.targetWeight,
    required this.startDate,
    required this.targetDate,
    required this.strategy,
    required this.status,
  });

  final String id;
  final double startWeight;
  final double targetWeight;
  final DateTime startDate;
  final DateTime targetDate;
  final GoalStrategy strategy;
  final GoalStatus status;

  String get strategyLabel => switch (strategy) {
        GoalStrategy.suggestedByImc => 'Meta sugerida pelo IMC',
        GoalStrategy.custom => 'Meta personalizada',
      };

  String get statusLabel => switch (status) {
        GoalStatus.active => 'Ativa',
        GoalStatus.completed => 'Concluída',
        GoalStatus.cancelled => 'Cancelada',
      };

  bool get isActive => status == GoalStatus.active;

  bool isReachedBy(double weight) {
    if (targetWeight <= startWeight) {
      return weight <= targetWeight;
    }
    return weight >= targetWeight;
  }

  GoalPlan copyWith({
    String? id,
    double? startWeight,
    double? targetWeight,
    DateTime? startDate,
    DateTime? targetDate,
    GoalStrategy? strategy,
    GoalStatus? status,
  }) {
    return GoalPlan(
      id: id ?? this.id,
      startWeight: startWeight ?? this.startWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      strategy: strategy ?? this.strategy,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startWeight': startWeight,
      'targetWeight': targetWeight,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'strategy': strategy.name,
      'status': status.name,
    };
  }

  factory GoalPlan.fromJson(Map<String, dynamic> json) {
    return GoalPlan(
      id: json['id'] as String,
      startWeight: (json['startWeight'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: DateTime.parse(json['targetDate'] as String),
      strategy: GoalStrategy.values.firstWhere(
        (value) => value.name == json['strategy'],
        orElse: () => GoalStrategy.custom,
      ),
      status: GoalStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => (json['isActive'] as bool? ?? false) ? GoalStatus.active : GoalStatus.completed,
      ),
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.initialWeight,
    required this.heightCm,
    required this.sex,
    required this.birthDate,
    required this.goals,
  });

  final String name;
  final double initialWeight;
  final double heightCm;
  final BiologicalSex sex;
  final DateTime birthDate;
  final List<GoalPlan> goals;

  GoalPlan? get activeGoal {
    final active = goals.where((goal) => goal.isActive);
    if (active.isNotEmpty) {
      return active.first;
    }
    return null;
  }

  List<GoalPlan> get goalHistory {
    final history = goals.where((goal) => !goal.isActive).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return history;
  }

  GoalPlan? get latestGoal {
    if (goals.isEmpty) {
      return null;
    }
    final sortedGoals = [...goals]..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sortedGoals.first;
  }

  double? get goalWeight => activeGoal?.targetWeight;
  GoalStrategy? get goalStrategy => activeGoal?.strategy;

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

  String get goalStrategyLabel => activeGoal?.strategyLabel ?? 'Sem meta ativa';

  UserProfile copyWith({
    String? name,
    double? initialWeight,
    double? heightCm,
    BiologicalSex? sex,
    DateTime? birthDate,
    List<GoalPlan>? goals,
  }) {
    return UserProfile(
      name: name ?? this.name,
      initialWeight: initialWeight ?? this.initialWeight,
      heightCm: heightCm ?? this.heightCm,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      goals: goals ?? this.goals,
    );
  }

  UserProfile startNewGoal({
    required double startWeight,
    required double targetWeight,
    required DateTime startDate,
    required DateTime targetDate,
    required GoalStrategy strategy,
  }) {
    final replacementStatus = activeGoal?.isReachedBy(startWeight) ?? false
        ? GoalStatus.completed
        : GoalStatus.cancelled;
    final archivedGoals = [
      for (final goal in goals)
        if (goal.isActive) goal.copyWith(status: replacementStatus) else goal,
    ];

    final newGoal = GoalPlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startWeight: startWeight,
      targetWeight: targetWeight,
      startDate: startDate,
      targetDate: targetDate,
      strategy: strategy,
      status: GoalStatus.active,
    );

    return copyWith(goals: [...archivedGoals, newGoal]);
  }

  UserProfile endActiveGoal(GoalStatus status) {
    if (status == GoalStatus.active) {
      return this;
    }

    return copyWith(
      goals: [
        for (final goal in goals)
          if (goal.isActive) goal.copyWith(status: status) else goal,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'initialWeight': initialWeight,
      'heightCm': heightCm,
      'sex': sex.name,
      'birthDate': birthDate.toIso8601String(),
      'goals': goals.map((goal) => goal.toJson()).toList(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final storedGoals = (json['goals'] as List<dynamic>?)
        ?.whereType<Map>()
        .map((entry) => GoalPlan.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    final initialWeight = (json['initialWeight'] as num).toDouble();
    final fallbackStrategy = GoalStrategy.values.firstWhere(
      (value) => value.name == json['goalStrategy'],
      orElse: () => GoalStrategy.custom,
    );
    final fallbackGoalWeight = (json['goalWeight'] as num?)?.toDouble() ?? initialWeight;
    final fallbackGoals = [
      GoalPlan(
        id: 'legacy-initial-goal',
        startWeight: initialWeight,
        targetWeight: fallbackGoalWeight,
        startDate: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 90)),
        strategy: fallbackStrategy,
        status: GoalStatus.active,
      ),
    ];

    return UserProfile(
      name: json['name'] as String,
      initialWeight: initialWeight,
      heightCm: (json['heightCm'] as num).toDouble(),
      sex: BiologicalSex.values.firstWhere(
        (value) => value.name == json['sex'],
        orElse: () => BiologicalSex.male,
      ),
      birthDate: DateTime.parse(json['birthDate'] as String),
      goals: storedGoals == null || storedGoals.isEmpty ? fallbackGoals : storedGoals,
    );
  }
}
