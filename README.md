# 🌳 自律森林 (Self-Discipline Forest)

> 最好的自律App — 番茄钟+种树+习惯追踪+长期计划+App锁定+间隔复习

## 为什么做这个

市面上没有一款App同时做到：
- 🍅 番茄钟（25+5循环专注）
- 🌳 种树游戏化（Forest的损失厌恶机制）
- ✅ 科学习惯追踪（Loop Habit Tracker的健康度算法）
- 🎯 长期目标分解（LifeOps的身份驱动设计）
- 🔒 App锁定（Forest的严格模式+有限紧急解锁）
- 🧠 间隔复习（艾宾浩斯遗忘曲线）

这个App把六合一。

## 功能一览

| 功能 | 说明 | 状态 |
|------|------|------|
| 番茄钟 | 25/5标准模式 + Flowmodoro自适应 + 自定义时长 | ✅ |
| 种树引擎 | 8种树型 × 5个生长阶段 × 枯萎/受伤机制 | ✅ |
| SVG倒计时环 | 60fps CustomPainter动画 | ✅ |
| 注意力标记 | Flowmodoro实时注意力评估 | ✅ |
| 习惯打卡 | 健康度评分(0-100%) + 连续天数 + 热力图 | ✅ |
| 微习惯阶梯 | 三级难度自动调节 | 🔜 |
| 长期计划 | 目标分解树（5年→年→月→周→日） | 🔜 |
| App锁定 | 专注模式锁定+白名单+紧急解锁(3次/天扣积分) | 🔜 |
| 积分商店 | 种树得积分→解锁稀有树种+主题 | 🔜 |
| 间隔复习 | SM-2算法自动排期 | 🔜 |
| 知识库同步 | 关联桌面知识库 | 🔜 |

## 技术栈

```
Flutter 3.x + Dart 3.x
├── Riverpod — 状态管理（编译时安全）
├── Drift(SQLite) — 本地持久化
├── CustomPainter — 种树动画+倒计时环（60fps）
├── Ticker — vsync同步精确计时（参考focus-timer的rAF方案）
├── fl_chart — 统计图表
├── WorkManager — 后台计时+通知
└── AccessibilityService — Android App锁定
```

## 学习来源

| 仓库 | 学了什么 |
|------|---------|
| [专注森林Flutter版](https://ai6s.net/69d3c98c0a2f6a37c59d67c9.html) | 树型设计、生长动画、CustomPainter |
| [focus-timer](https://github.com/elitepunith/focus-timer) | requestAnimationFrame精确定时、SVG倒计时环 |
| [Loop Habit Tracker](https://github.com/iSoron/uhabits) | 健康度算法、热力图、习惯数据模型 |
| [MasteryTrack](https://github.com/Alpha-Mintamir/MasteryTrack) | App白名单/黑名单、空闲检测 |
| [LifeOps](https://github.com/shadkhan/LifeOps) | 目标分解树、身份驱动习惯 |
| [LifeHabit](https://github.com/pythonlei/life_habit_web) | 微习惯阶梯、奖励机制 |

## 项目结构

```
lib/
├── main.dart              ← App入口 + Material Design 3主题
├── models/
│   ├── timer_session.dart ← 番茄钟会话模型
│   ├── tree.dart          ← 种树引擎（8种树×5阶段）
│   ├── habit.dart         ← 习惯追踪（健康度算法）
│   └── goal.dart          ← 长期目标分解
├── services/
│   ├── timer_service.dart ← 计时器核心（Ticker vsync）
│   ├── notification_service.dart
│   ├── app_lock_service.dart
│   └── spaced_repetition.dart
├── providers/             ← Riverpod状态管理
├── screens/
│   ├── focus_screen.dart  ← 🍅 专注种树主页
│   ├── habits_screen.dart ← ✅ 习惯打卡+热力图
│   ├── plan_screen.dart   ← 🎯 长期计划
│   ├── forest_screen.dart ← 🌳 我的森林
│   └── profile_screen.dart← 👤 统计+设置
└── widgets/
    ├── countdown_ring.dart← SVG倒计时环
    └── tree_widget.dart   ← 种树动画组件
```

## 运行

```bash
# 1. 安装Flutter SDK
# https://docs.flutter.dev/get-started/install

# 2. 克隆项目
cd self-discipline-app

# 3. 安装依赖
flutter pub get

# 4. 运行
flutter run
```

## 开发计划

- [x] Week 1：项目骨架 + 计时器 + 种树动画
- [x] Week 2：习惯追踪 + 统计面板
- [ ] Week 3：长期计划 + App锁定
- [ ] Week 4：奖励系统 + 放松引导
- [ ] Week 5：间隔复习 + 知识库联动
- [ ] Week 6：打磨UI + 打包发布

## License

MIT
