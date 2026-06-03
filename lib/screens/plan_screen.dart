/// 长期计划页面
/// 参考：LifeOps的目标分解树 + Meditations的极简UI

import 'package:flutter/material.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('长期计划'), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 提示卡片
          Card(
            color: theme.colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 目标分解法则', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('大目标 → 年度目标 → 季度里程碑 → 月计划 → 周任务 → 每日待办\n\n每个节点预估需要的番茄钟数。完成下层自动推进上层进度。'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 目标树
          _GoalNode(
            title: '🎓 大学顺利毕业',
            subtitle: '2027年6月',
            progress: 0.45,
            color: theme.colorScheme.primary,
            children: [
              _GoalNode(title: '📚 本学期GPA 3.5+', subtitle: '6月底 · 预估120个🍅', progress: 0.6, color: Colors.blue,
                children: [
                  _GoalNode(title: '有机化学B > 85分', subtitle: '已完成80个🍅 · 剩余40个', progress: 0.67, color: Colors.teal),
                  _GoalNode(title: '大学物理 > 80分', subtitle: '预估60个🍅', progress: 0.3, color: Colors.teal),
                ],
              ),
              _GoalNode(title: '💻 编程能力达到实习水平', subtitle: 'Python + C · 预估200个🍅', progress: 0.25, color: Colors.orange,
                children: [
                  _GoalNode(title: '每日一题坚持90天', subtitle: 'Day 7/90 · 预估90个🍅', progress: 0.08, color: Colors.deepOrange),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final List<_GoalNode>? children;

  const _GoalNode({required this.title, required this.subtitle, required this.progress, required this.color, this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text('${(progress * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.grey.shade200, color: color),
                  ),
                ],
              ),
            ),
          ),
          if (children != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(children: children!),
            ),
        ],
      ),
    );
  }
}
