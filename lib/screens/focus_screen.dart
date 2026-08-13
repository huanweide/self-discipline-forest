/// 专注种树页面 — App主页面
/// 番茄钟计时器 + 种树动画 + 快速模式切换

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/timer_service.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/tree_widget.dart';

/// 当前计时器状态
final selectedDurationProvider = StateProvider<int>((ref) => 25); // 默认25分钟

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});
  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late FocusTimerService _timerService;
  bool _isRunning = false; // 结构态：是否正在计时（仅开始/结束时变化，非每帧）
  bool _isBreak = false;

  // 预设时长选项
  static const _presetDurations = [15, 25, 30, 45, 60];
  static const _presetLabels = ['15分', '25分', '30分', '45分', '60分'];

  @override
  void initState() {
    super.initState();
    _timerService = FocusTimerService(focusMinutes: 25);
    _timerService.onFocusComplete = () {
      setState(() => _isRunning = false);
      _showCompletionDialog('🎉 专注完成！', '一棵树成熟了！');
    };
    _timerService.onBreakComplete = () {
      setState(() {
        _isBreak = false;
        _isRunning = false;
      });
    };
    _timerService.onInterrupted = () {
      _showCompletionDialog('😢 树受伤了', '下次坚持住！');
    };
    _timerService.onAbandoned = () {
      _showCompletionDialog('😢 树枯萎了', '下次坚持住！');
    };
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 仅对 paused/detached 计数；inactive（iOS 控制中心/来电横幅等瞬态）不计，避免误累加
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _timerService.interrupt();
    } else if (state == AppLifecycleState.resumed) {
      _timerService.resetInterruptCount();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerService.dispose();
    super.dispose();
  }

  void _startFocus() {
    final minutes = ref.read(selectedDurationProvider);
    // 复用前先释放旧实例（含其 Ticker），避免每次新建 FocusTimerService 泄漏
    _timerService.dispose();
    _timerService = FocusTimerService(focusMinutes: minutes)
      ..onFocusComplete = () {
        setState(() => _isRunning = false);
        _showCompletionDialog('🎉 专注完成！', '一棵树成熟了！');
      }
      ..onBreakComplete = () => setState(() { _isBreak = false; _isRunning = false; })
      ..onInterrupted = () => _showCompletionDialog('😢 树受伤了', '下次坚持住！')
      ..onAbandoned = () => _showCompletionDialog('😢 树枯萎了', '下次坚持住！');
    _timerService.start(this);
    setState(() {
      _isBreak = false;
      _isRunning = true;
    });
  }

  void _startBreak() {
    _timerService.startBreak(this, breakMinutes: 5);
    setState(() {
      _isBreak = true;
      _isRunning = true;
    });
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
                setState(() { _isRunning = false; _isBreak = false; });
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
    // 结构态：是否正在计时（仅开始/结束时变化），用于决定时长选择/主按钮/注意力行的显示，
    // 不随每帧 tick 变化，因此这些子树不会被 60fps 的动画回调重建（IMP-107）。
    final isRunning = _isRunning;

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

              // === 树动画区 + 倒计时环：仅此子树随每帧 tick 更新（IMP-107）===
              // 通过 AnimatedBuilder 监听 stateNotifier，把 ~60次/秒的重建
              // 限制在该子树内，时长选择/主按钮/注意力行不再被无谓重建。
              AnimatedBuilder(
                animation: _timerService.stateNotifier,
                builder: (context, _) {
                  final s = _timerService.stateNotifier.value;
                  return Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: TreeWidget(
                          progress: s.progress,
                          isRunning: s.isRunning,
                          isBreak: _isBreak,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CountdownRing(
                        progress: s.progress,
                        timeText: s.timeRemainingFormatted,
                        isRunning: s.isRunning,
                        isBreak: _isBreak,
                        size: 200,
                      ),
                    ],
                  );
                },
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
                    if (_isBreak) {
                      _timerService.dispose();
                      setState(() {
                        _isRunning = false;
                        _isBreak = false;
                      });
                    } else {
                      _timerService.abandon();
                      setState(() {
                        _isRunning = false;
                        _isBreak = false;
                      });
                      _timerService.dispose();
                    }
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
          Text(label.split(' ').length > 1 ? label.split(' ')[1] : '',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
