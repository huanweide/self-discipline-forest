/// 我的森林——所有种过的树的展示页
/// 参考：Forest App的GridView森林展示 + Loop Habit Tracker的热力图

import 'package:flutter/material.dart';
import '../widgets/tree_widget.dart';

class ForestScreen extends StatelessWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的森林'), centerTitle: true),
      body: Column(
        children: [
          // 统计卡片
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(icon: Icons.nature, value: '12', label: '总种树', color: theme.colorScheme.primary),
                    _StatItem(icon: Icons.auto_awesome, value: '8', label: '存活', color: Colors.green),
                    _StatItem(icon: Icons.dangerous, value: '3', label: '枯萎', color: Colors.red),
                    _StatItem(icon: Icons.local_fire_department, value: '5', label: '今日', color: Colors.orange),
                  ],
                ),
              ),
            ),
          ),
          // 森林网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                // 模拟不同类型的树
                final stages = [TreeStage.mature, TreeStage.mature, TreeStage.blooming,
                    TreeStage.withered, TreeStage.mature, TreeStage.blooming,
                    TreeStage.mature, TreeStage.mature, TreeStage.mature,
                    TreeStage.damaged, TreeStage.mature, TreeStage.seed];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        child: TreeWidget(
                          progress: stages[index] == TreeStage.mature ? 1.0 : 0.6,
                          forcedStage: stages[index],
                        ),
                      ),
                      Text(
                        ['橡树','松树','樱花','枯树','竹子','枫树','柳树','橡树','仙人掌','受伤','红杉','新种'][index],
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
