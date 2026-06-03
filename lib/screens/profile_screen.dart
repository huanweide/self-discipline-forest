/// 个人中心——统计+设置+积分商店
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.person, size: 35)),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('斯瑞', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('积分: 1,280 🌟', style: TextStyle(color: theme.colorScheme.primary)),
                    Text('连续专注: 5天 🔥', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 本周统计图表
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('本周专注时长', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 180,
                        barGroups: [
                          _makeBar(0, 120, '周一'), _makeBar(1, 150, '周二'),
                          _makeBar(2, 90, '周三'), _makeBar(3, 165, '周四'),
                          _makeBar(4, 80, '周五'), _makeBar(5, 140, '周六'),
                          _makeBar(6, 60, '周日'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 成就
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏆 成就', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _achievement('🌱', '初次种树', true),
                    _achievement('🔥', '连续7天', true),
                    _achievement('🌲', '10棵树', true),
                    _achievement('📚', '100个番茄', false),
                    _achievement('⭐', '1000积分', false),
                    _achievement('🏅', '30天不间断', false),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 设置入口
          Card(
            child: Column(
              children: [
                _settingItem(Icons.notifications_outlined, '通知设置', () {}),
                _settingItem(Icons.lock_outline, 'App锁定设置', () {}),
                _settingItem(Icons.palette_outlined, '主题设置', () {}),
                _settingItem(Icons.backup_outlined, '数据备份', () {}),
                _settingItem(Icons.info_outline, '关于', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, String label) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: const Color(0xFF4CAF50), width: 16,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
    ]);
  }

  Widget _achievement(String icon, String name, bool unlocked) {
    return Chip(
      avatar: Text(icon),
      label: Text(name, style: TextStyle(fontSize: 12, color: unlocked ? null : Colors.grey)),
      backgroundColor: unlocked ? Colors.green.shade50 : Colors.grey.shade100,
    );
  }

  Widget _settingItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
