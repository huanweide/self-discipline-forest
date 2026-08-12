/// 番茄钟计时器引擎
/// 参考：focus-timer的requestAnimationFrame精确定时方案
///       Flowmodoro自适应模式来自tomdeabreucodes/flowmodorotimer

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// 计时器状态回调
typedef TimerCallback = void Function(TimerState state);

class TimerState {
  final int elapsedSeconds;       // 已过秒数
  final int totalSeconds;          // 总秒数
  final double progress;           // 0.0~1.0
  final bool isRunning;
  final bool isBreak;
  final TimerMode mode;

  TimerState({
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.isRunning,
    this.isBreak = false,
    this.mode = TimerMode.pomodoro,
  }) : progress = totalSeconds > 0
            ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0)
            : 0.0;

  String get timeRemainingFormatted {
    final remaining = totalSeconds - elapsedSeconds;
    final m = remaining ~/ 60;
    final s = remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  TimerState copyWith({
    int? elapsedSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isBreak,
  }) => TimerState(
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    totalSeconds: totalSeconds ?? this.totalSeconds,
    isRunning: isRunning ?? this.isRunning,
    isBreak: isBreak ?? this.isBreak,
    mode: mode,
  );
}

enum TimerMode { pomodoro, flowmodoro, custom }

/// Flowmodoro评分：实时评估注意力状态
/// 心跳稳定性 + 微动检测（通过加速度计或者手动标记）
enum AttentionLevel { deep, focused, drifting, distracted }

class FocusTimerService {
  Timer? _timer;
  Ticker? _ticker; // vsync-based ticker for smoother animation
  TimerState _state;
  DateTime? _startedAt;          // 本次计时的真实起点
  int _baseElapsedSeconds = 0;   // 本次运行前的累计秒数（支持暂停/恢复）
  TimerCallback? onTick;
  VoidCallback? onFocusComplete;
  VoidCallback? onBreakComplete;
  VoidCallback? onInterrupted;
  VoidCallback? onAbandoned;

  // Flowmodoro模式专用
  AttentionLevel _attentionLevel = AttentionLevel.focused;
  final List<AttentionLevel> _attentionHistory = [];
  int _interruptCount = 0;            // 离开App的中断次数（interrupt）
  int _attentionDistractedCount = 0;  // 手动标记分心的次数（markAttention）
  static const int _interruptThreshold = 3; // 3次离开→结束番茄钟
  static const int _distractedThreshold = 3; // 3次分心→结束番茄钟

  FocusTimerService({required int focusMinutes})
      : _state = TimerState(
          elapsedSeconds: 0,
          totalSeconds: focusMinutes * 60,
          isRunning: false,
        );

  TimerState get state => _state;
  AttentionLevel get attentionLevel => _attentionLevel;

  /// 开始计时——使用Ticker实现vsync同步的精确计时
  /// 参考focus-timer的requestAnimationFrame方案
  void start(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
    _baseElapsedSeconds = _state.elapsedSeconds;
    _startedAt = DateTime.now();
    _state = TimerState(
      elapsedSeconds: _state.elapsedSeconds,
      totalSeconds: _state.totalSeconds,
      isRunning: true,
      isBreak: _state.isBreak,
      mode: _state.mode,
    );
    _ticker!.start();
  }

  void _onTick(Duration _) {
    if (_startedAt == null) return;
    final newElapsed = _baseElapsedSeconds +
        DateTime.now().difference(_startedAt!).inSeconds.abs();
    _state = _state.copyWith(elapsedSeconds: newElapsed);
    onTick?.call(_state);

    // 检查是否完成
    if (newElapsed >= _state.totalSeconds) {
      _ticker?.stop();
      _state = _state.copyWith(isRunning: false);
      if (_state.isBreak) {
        onBreakComplete?.call();
      } else {
        onFocusComplete?.call();
      }
    }
  }

  /// 暂停——仅在Flowmodoro模式下允许暂停
  void pause() {
    _ticker?.stop();
    _state = _state.copyWith(isRunning: false);
  }

  /// 恢复
  void resume(TickerProvider vsync) {
    _ticker?.stop();
    start(vsync);
  }

  /// 中断（用户离开App）——树受伤
  /// 参考Forest的"离开即枯萎"机制，但我们给3次机会
  void interrupt() {
    _interruptCount++;
    if (_interruptCount >= _interruptThreshold) {
      _ticker?.stop();
      _state = _state.copyWith(isRunning: false);
      onInterrupted?.call();
    }
  }

  /// 放弃（用户主动退出）——树枯萎
  void abandon() {
    _ticker?.stop();
    _state = _state.copyWith(isRunning: false);
    onAbandoned?.call();
  }

  /// 重置中断计数（回到App）
  void resetInterruptCount() {
    _interruptCount = 0;
    _attentionDistractedCount = 0;
  }

  /// Flowmodoro模式：手动标记当前注意力水平
  /// 参考：Flowmodoro的分心即结束理念
  void markAttention(AttentionLevel level) {
    _attentionLevel = level;
    _attentionHistory.add(level);
    if (level == AttentionLevel.distracted) {
      _attentionDistractedCount++;
      if (_attentionDistractedCount >= _distractedThreshold && _state.mode == TimerMode.flowmodoro) {
        _ticker?.stop();
        _state = _state.copyWith(isRunning: false);
        onFocusComplete?.call(); // 提前结束，计算比例休息
      }
    }
  }

  /// 计算Flowmodoro的休息时长
  /// breakTime = focusTime / divisor
  /// divisor默认5（即1小时专注→12分钟休息）
  int calculateFlowmodoroBreak({double divisor = 5.0}) {
    return (_state.elapsedSeconds / divisor).round();
  }

  /// 开始休息倒计时
  void startBreak(TickerProvider vsync, {int? breakMinutes}) {
    final breakSecs = breakMinutes != null
        ? breakMinutes * 60
        : calculateFlowmodoroBreak();
    _state = TimerState(
      elapsedSeconds: 0,
      totalSeconds: breakSecs,
      isRunning: true,
      isBreak: true,
      mode: _state.mode,
    );
    start(vsync);
  }

  void dispose() {
    _ticker?.dispose();
    _timer?.cancel();
  }
}
