/// 种树引擎数据模型
/// 参考：Forest App机制 + 专注森林Flutter版的8种树型设计

enum TreeType {
  oak,        // 橡树 —— 基础树，0积分解锁
  pine,       // 松树 —— 连续3天解锁
  cherry,     // 樱花 —— 500积分解锁
  bamboo,     // 竹子 —— 7天连续打卡
  cactus,     // 仙人掌 —— 1000积分解锁
  maple,      // 枫树 —— 完成10个目标解锁
  willow,     // 柳树 —— 2000积分解锁
  redwood,    // 红杉 —— 5000积分解锁（最高荣誉）
}

enum TreeStage {
  seed,       // 种子 —— 0~20%
  sprout,     // 发芽 —— 20~40%
  growing,    // 生长 —— 40~70%
  blooming,   // 开花 —— 70~95%
  mature,     // 成熟 —— 95~100%
  withered,   // 枯萎 —— 中途放弃
  damaged,    // 受伤 —— 被紧急解锁打断
}

/// 一棵树 = 一次专注会话的结果
class Tree {
  final String id;
  final String sessionId;       // 关联的番茄钟会话
  final TreeType type;
  final TreeStage stage;
  final DateTime plantedAt;     // 种下时间（=开始专注）
  final DateTime? maturedAt;    // 成熟时间（=完成专注）
  final int earnedPoints;       // 这棵树得到的积分

  Tree({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.stage,
    required this.plantedAt,
    this.maturedAt,
    this.earnedPoints = 0,
  });

  /// 根据专注进度计算生长阶段
  static TreeStage stageFromProgress(double progress, {
    bool abandoned = false,
    bool interrupted = false,
  }) {
    if (abandoned) return TreeStage.withered;
    if (interrupted) return TreeStage.damaged;
    if (progress < 0.2) return TreeStage.seed;
    if (progress < 0.4) return TreeStage.sprout;
    if (progress < 0.7) return TreeStage.growing;
    if (progress < 0.95) return TreeStage.blooming;
    return TreeStage.mature;
  }

  /// 每种树的积分奖励
  static int pointsForType(TreeType type) {
    switch (type) {
      case TreeType.oak: return 10;
      case TreeType.pine: return 15;
      case TreeType.cherry: return 20;
      case TreeType.bamboo: return 25;
      case TreeType.cactus: return 30;
      case TreeType.maple: return 40;
      case TreeType.willow: return 50;
      case TreeType.redwood: return 100;
    }
  }

  /// 树的显示名称
  static String displayName(TreeType type) {
    switch (type) {
      case TreeType.oak: return '橡树';
      case TreeType.pine: return '松树';
      case TreeType.cherry: return '樱花';
      case TreeType.bamboo: return '竹子';
      case TreeType.cactus: return '仙人掌';
      case TreeType.maple: return '枫树';
      case TreeType.willow: return '柳树';
      case TreeType.redwood: return '红杉';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'type': type.name,
    'stage': stage.name,
    'plantedAt': plantedAt.toIso8601String(),
    'maturedAt': maturedAt?.toIso8601String(),
    'earnedPoints': earnedPoints,
  };

  factory Tree.fromJson(Map<String, dynamic> json) => Tree(
    id: json['id'],
    sessionId: json['sessionId'],
    type: TreeType.values.byName(json['type']),
    stage: TreeStage.values.byName(json['stage']),
    plantedAt: DateTime.parse(json['plantedAt']),
    maturedAt: json['maturedAt'] != null ? DateTime.parse(json['maturedAt']) : null,
    earnedPoints: json['earnedPoints'],
  );
}

/// 用户森林 = 所有树的集合
class Forest {
  final List<Tree> trees;

  Forest({required this.trees});

  /// 今日种了几棵
  int get todayCount => trees
      .where((t) => t.plantedAt.day == DateTime.now().day)
      .length;

  /// 总共种活了几棵（不含枯萎和受伤）
  int get aliveCount => trees
      .where((t) => t.stage == TreeStage.mature)
      .length;

  /// 总共枯萎了几棵（损失厌恶可视化）
  int get witheredCount => trees
      .where((t) => t.stage == TreeStage.withered)
      .length;

  /// 按类型统计
  Map<TreeType, int> get countByType {
    final map = <TreeType, int>{};
    for (final t in trees) {
      if (t.stage == TreeStage.mature) {
        map[t.type] = (map[t.type] ?? 0) + 1;
      }
    }
    return map;
  }
}
