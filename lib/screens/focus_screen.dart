/// 专注种树页面 — App主页面
/// 番茄钟计时器 + 种树动画 + 快速模式切换

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/timer_service.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/tree_widget.dart';

/// 当前计时器状态
final timerProvider = StateProvider<FocusTimerService?>((ref) => null);
final timerStateProvider = StateProvider<TimerState?>((ref) => null);
final selectedDurationProvider = StateProvider<int>((ref) => 25); // 默认25分钟

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});
  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with SingleTickerProviderStateMixin {
  late FocusTimerService _timerService;
  TimerState? _timerState;
  bool _isBreak = false;

  // 预设时长选项
  static const _presetDurations = [15, 25, 30, 45, 60];
  static const _presetLabels = ['15分', '25分', '30分', '45分', '60分'];

  @override
  void initState() {
    super.initState();
    _timerService = FocusTimerService(focusMinutes: 25);
    _timerService.onTick = (state) {
      setState(() => _timerState = state);
    };
    _timerService.onFocusComplete = () {
      _showCompletionDialog('🎉 专注完成！', '一棵树成熟了！');
    };
    _timerService.onBreakComplete = () {
      setState(() {
        _isBreak = false;
        _timerState = null;
      });
    };
    _timerService.onInterrupted = () {
      _showCompletionDialog('😢 树枯萎了', '下次坚持住！');
    };
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  void _startFocus() {
    final minutes = ref.read(selectedDurationProvider);
    _timerService = FocusTimerService(focusMinutes: minutes)
      ..onTick = (state) => setState(() => _timerState = state)
      ..onFocusComplete = () => _showCompletionDialog('🎉 专注完成！', '一棵树成熟了！')
      ..onBreakComplete = () => setState(() { _isBreak = false; _timerState = null; })
      ..onInterrupted = () => _showCompletionDialog('😢 树枯萎了', '下次坚持住！');
    _timerService.start(this);
    setState(() => _isBreak = false);
  }

  void _startBreak() {
    _timerService.startBreak(this, breakMinutes: 5);
    setState(() => _isBreak = true);
  }

  void _showCompletionDialog(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          if (!_isBreak)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _startBreak();
              },
              child: const Text('休息5分钟'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _timerState = null; _isBreak = false; });
            },
            child: const Text('结束'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = _timerState?.isRunning ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('专注种树'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // === 树动画区 ===
              SizedBox(
                height: 220,
                child: TreeWidget(
                  progress: _timerState?.progress ?? 0.0,
                  isRunning: isRunning,
                  isBreak: _isBreak,
                ),
              ),

              const SizedBox(height: 20),

              // === 倒计时环 ===
              CountdownRing(
                progress: _timerState?.progress ?? 0.0,
                timeText: _timerState?.timeRemainingFormatted ?? '25:00',
                isRunning: isRunning,
                isBreak: _isBreak,
                size: 200,
              ),

              const SizedBox(height: 20),

              // === 状态标签 ===
              if (_isBreak)
                Chip(
                  avatar: const Icon(Icons.coffee, size: 18),
                  label: const Text('休息中 ☕'),
                  backgroundColor: Colors.orange.shade100,
                )
              else if (isRunning)
                Chip(
                  avatar: const Icon(Icons.local_fire_department, size: 18),
                  label: const Text('专注中 🔥'),
                  backgroundColor: Colors.green.shade100,
                ),

              const SizedBox(height: 20),

              // === 时长选择（未开始时显示）===
              if (!isRunning)
                Column(
                  children: [
                    const Text('选择专注时长', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: List.generate(_presetDurations.length, (i) {
                        final selected = ref.watch(selectedDurationProvider) == _presetDurations[i];
                        return ChoiceChip(
                          label: Text(_presetLabels[i]),
                          selected: selected,
                          onSelected: (_) => ref.read(selectedDurationProvider.notifier).state = _presetDurations[i],
                          selectedColor: theme.colorScheme.primaryContainer,
                        );
                      }),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              // === 开始/暂停按钮 ===
              if (!isRunning)
                _buildMainButton('🌱 开始种树', _startFocus, theme.colorScheme.primary)
              else
                _buildMainButton(
                  _isBreak ? '跳过休息' : '放弃这棵树',
                  () {
                    _timerService.dispose();
                    _timerService.onInterrupted?.call();
                  },
                  Colors.red,
                ),

              const SizedBox(height: 30),

              // === Flowmodoro注意力标记（仅运行中显示）===
              if (isRunning && !_isBreak)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attentionButton('🔥 深度专注', AttentionLevel.deep, Colors.deepPurple),
                    _attentionButton('👍 专注', AttentionLevel.focused, Colors.green),
                    _attentionButton('😐 走神', AttentionLevel.drifting, Colors.orange),
                    _attentionButton('📱 分心', AttentionLevel.distracted, Colors.red),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(String label, VoidCallback onTap, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.nature, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }

  Widget _attentionButton(String label, AttentionLevel level, Color color) {
    return GestureDetector(
      onTap: () => _timerService.markAttention(level),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _timerService.attentionLevel == level
                  ? color.withOpacity(0.2)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: _timerService.attentionLevel == level ? color : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(child: Text(label.split(' ')[0], style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(height: 4),
          Text(label.split(' ')[1], style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
