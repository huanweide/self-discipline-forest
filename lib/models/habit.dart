/// 习惯追踪数据模型
/// 参考：Loop Habit Tracker的健康度算法 + LifeHabit的微习惯阶梯

enum HabitFrequency { daily, weekly, customDays }

enum DifficultyTier {
  micro,    // 微习惯：100%能做到（如1个俯卧撑）
  normal,   // 正常：80%能做到
  challenge,// 挑战：50%能做到
}

class Habit {
  final String id;
  final String name;
  final String description;
  final HabitFrequency frequency;
  final List<int> activeDays;     // 自定义频率：哪些天活跃 [1,3,5] = 周一三五
  final DateTime createdAt;
  final DifficultyTier currentTier; // 当前难度阶梯
  final List<DateTime> completions; // 完成日期列表
  final int streak;               // 连续天数
  final int bestStreak;           // 历史最长连续
  final double healthScore;       // 健康度 0.0~100.0

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.frequency = HabitFrequency.daily,
    this.activeDays = const [1,2,3,4,5,6,7],
    required this.createdAt,
    this.currentTier = DifficultyTier.micro,
    this.completions = const [],
    this.streak = 0,
    this.bestStreak = 0,
    this.healthScore = 0.0,
  });

  /// Loop Habit Tracker的健康度算法：
  /// 健康度 = (近期完成率 × 0.7) + (历史完成率 × 0.3) × 100
  /// 14天内的完成率权重70%，全部历史的完成率权重30%
  static double calculateHealthScore({
    required List<DateTime> completions,
    required HabitFrequency frequency,
    required List<int> activeDays,
  }) {
    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    // 近14天应该完成的次数
    int expectedRecent = 0;
    int completedRecent = 0;
    for (var d = fourteenDaysAgo; d.isBefore(now); d = d.add(const Duration(days: 1))) {
      if (_isActiveDay(d, frequency, activeDays)) {
        expectedRecent++;
        if (completions.any((c) => c.year == d.year && c.month == d.month && c.day == d.day)) {
          completedRecent++;
        }
      }
    }

    // 全部历史应该完成的次数
    int expectedTotal = 0;
    int completedTotal = 0;
    if (completions.isNotEmpty) {
      final firstDay = completions.reduce((a, b) => a.isBefore(b) ? a : b);
      for (var d = firstDay; d.isBefore(now); d = d.add(const Duration(days: 1))) {
        if (_isActiveDay(d, frequency, activeDays)) {
          expectedTotal++;
          if (completions.any((c) => c.year == d.year && c.month == d.month && c.day == d.day)) {
            completedTotal++;
          }
        }
      }
    }

    final recentRate = expectedRecent > 0 ? completedRecent / expectedRecent : 0.0;
    final totalRate = expectedTotal > 0 ? completedTotal / expectedTotal : 0.0;
    return ((recentRate * 0.7 + totalRate * 0.3) * 100).clamp(0.0, 100.0);
  }

  static bool _isActiveDay(DateTime date, HabitFrequency freq, List<int> days) {
    switch (freq) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return true; // 每周任何一天都算
      case HabitFrequency.customDays:
        return days.contains(date.weekday); // 1=Mon, 7=Sun
    }
  }

  /// 微习惯阶梯自动调节：
  /// 连续14天成功→升级难度
  /// 连续7天失败→降级难度
  DifficultyTier calculateNextTier(int recentStreak, int recentMisses) {
    if (recentStreak >= 14 && currentTier != DifficultyTier.challenge) {
      return DifficultyTier.values[DifficultyTier.values.indexOf(currentTier) + 1];
    }
    if (recentMisses >= 7 && currentTier != DifficultyTier.micro) {
      return DifficultyTier.values[DifficultyTier.values.indexOf(currentTier) - 1];
    }
    return currentTier;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'frequency': frequency.name,
    'activeDays': activeDays,
    'createdAt': createdAt.toIso8601String(),
    'currentTier': currentTier.name,
    'completions': completions.map((d) => d.toIso8601String()).toList(),
    'streak': streak,
    'bestStreak': bestStreak,
    'healthScore': healthScore,
  };
}
