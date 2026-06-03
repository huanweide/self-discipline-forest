/// 番茄钟会话数据模型
/// 参考：Loop Habit Tracker的数据模型设计 + focus-timer的计时精度方案

enum TimerMode {
  pomodoro,    // 标准番茄钟 25+5
  flowmodoro,   // 自适应：注意力下降→计算比例休息
  custom,       // 自定义时长
}

enum SessionStatus {
  running,     // 进行中
  paused,      // 暂停（仅在flowmodoro模式）
  completed,   // 正常完成→树种活
  abandoned,   // 中途放弃→树枯萎
  interrupted, // 被紧急解锁打断→树受伤
}

class TimerSession {
  final String id;
  final TimerMode mode;
  final int focusMinutes;       // 预设专注时长（分钟）
  final int breakMinutes;       // 预设休息时长（分钟）
  final DateTime startedAt;
  DateTime? endedAt;
  SessionStatus status;
  int elapsedSeconds;           // 已过秒数
  int interruptionCount;        // 中断次数（离开App次数）

  TimerSession({
    required this.id,
    required this.mode,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    required this.startedAt,
    this.endedAt,
    this.status = SessionStatus.running,
    this.elapsedSeconds = 0,
    this.interruptionCount = 0,
  });

  /// 完成百分比 0.0 ~ 1.0
  double get progress {
    final total = focusMinutes * 60;
    if (total == 0) return 0;
    return (elapsedSeconds / total).clamp(0.0, 1.0);
  }

  /// 是否到达休息时间
  bool get shouldTakeBreak => elapsedSeconds >= focusMinutes * 60;

  /// 专注时长格式化 "25:00"
  String get focusTimeFormatted {
    final remaining = (focusMinutes * 60) - elapsedSeconds;
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 转为JSON（存SQLite）
  Map<String, dynamic> toJson() => {
    'id': id,
    'mode': mode.name,
    'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'status': status.name,
    'elapsedSeconds': elapsedSeconds,
    'interruptionCount': interruptionCount,
  };

  factory TimerSession.fromJson(Map<String, dynamic> json) => TimerSession(
    id: json['id'],
    mode: TimerMode.values.byName(json['mode']),
    focusMinutes: json['focusMinutes'],
    breakMinutes: json['breakMinutes'],
    startedAt: DateTime.parse(json['startedAt']),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    status: SessionStatus.values.byName(json['status']),
    elapsedSeconds: json['elapsedSeconds'],
    interruptionCount: json['interruptionCount'],
  );
}
