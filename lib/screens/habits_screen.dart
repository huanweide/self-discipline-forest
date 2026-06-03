/// 习惯追踪页面
/// 参考：Loop Habit Tracker的UI设计——健康度评分+热力图+打卡

import 'package:flutter/material.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  // 模拟数据（后期接入SQLite）
  final _habits = [
    _HabitData('每日编程', '每天一道Python/C题', 0.85, 14, true),
    _HabitData('英语单词', '每日20个新词+复习', 0.72, 7, true),
    _HabitData('早起', '7:00前起床', 0.63, 3, false),
    _HabitData('运动', '每天运动30分钟', 0.45, 1, false),
    _HabitData('阅读', '每天读书20页', 0.91, 21, true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('习惯追踪'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final h = _habits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 打卡按钮
                  GestureDetector(
                    onTap: () => setState(() => h.doneToday = !h.doneToday),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: h.doneToday ? theme.colorScheme.primary : Colors.grey.shade200,
                      ),
                      child: Icon(
                        h.doneToday ? Icons.check : Icons.circle_outlined,
                        color: h.doneToday ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 习惯信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(h.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 6),
                        // 健康度进度条
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: h.healthScore,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            color: _healthColor(h.healthScore),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 连续天数
                  Column(
                    children: [
                      Text('${h.streak}天', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      Text('连续', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // 热力图（底部）
      bottomNavigationBar: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本月打卡热力图', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Expanded(
              child: _buildHeatmap(),
            ),
          ],
        ),
      ),
    );
  }

  Color _healthColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.lightGreen;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildHeatmap() {
    // 简化的GitHub风格热力图
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 15,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final intensity = [0,1,2,3,4,0,1,4,3,2,0,2,4,3,1,0,0,3,4,2,1,0,2,3,4,0,1,2,3,0][index % 30];
        final colors = [
          Colors.grey.shade200,
          const Color(0xFFC8E6C9),
          const Color(0xFF81C784),
          const Color(0xFF4CAF50),
          const Color(0xFF2E7D32),
        ];
        return Container(
          decoration: BoxDecoration(
            color: colors[intensity],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}

class _HabitData {
  final String name;
  final String description;
  final double healthScore;
  final int streak;
  bool doneToday;

  _HabitData(this.name, this.description, this.healthScore, this.streak, this.doneToday);
}
