/// 自律App — 主入口
/// 集成：番茄钟+种树引擎+习惯追踪+长期计划+App锁定+间隔复习
///
/// 学习来源：
/// - timer: focus-timer (requestAnimationFrame精确定时)
/// - tree engine: 专注森林Flutter版 (CustomPainter动画)
/// - habits: Loop Habit Tracker (健康度算法)
/// - goals: LifeOps (身份驱动习惯)
/// - rewards: LifeHabit (游戏化阶梯)
/// - app lock: MasteryTrack (白名单/黑名单)
/// - spaced repetition: SM-2算法

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/focus_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/forest_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: SelfDisciplineApp()));
}

class SelfDisciplineApp extends StatelessWidget {
  const SelfDisciplineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '自律森林',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // 森林绿主色调
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'NotoSansSC',
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

/// 底部导航壳
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    FocusScreen(),    // 🍅 专注种树
    HabitsScreen(),   // ✅ 习惯打卡
    PlanScreen(),     // 🎯 长期计划
    ForestScreen(),   // 🌳 我的森林
    ProfileScreen(),  // 👤 统计+设置
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: '专注'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), label: '习惯'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: '计划'),
          NavigationDestination(icon: Icon(Icons.forest_outlined), label: '森林'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}
