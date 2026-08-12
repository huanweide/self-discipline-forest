<!-- badges -->
[![License](https://img.shields.io/github/license/huanweide/self-discipline-forest)](LICENSE)
[![CI](https://github.com/huanweide/self-discipline-forest/actions/workflows/ci.yml/badge.svg)](https://github.com/huanweide/self-discipline-forest/actions/workflows/ci.yml)
[![Stars](https://img.shields.io/github/stars/huanweide/self-discipline-forest)](https://github.com/huanweide/self-discipline-forest/stargazers)
<!-- /badges -->

# 自律森林 (Self-Discipline Forest)

> 把每一次专注「种」成一棵树——番茄钟 + 种树游戏化 + 习惯追踪的 Flutter 实验项目。
> 当前为**开发中原型**：核心计时与数据模型已成形，多数页面仍使用模拟数据。

## 项目简介

自律森林想把几件自律工具合并到一款 App 里：用番茄钟专注、用「种树」的游戏化机制对抗分心（参考 Forest 的损失厌恶）、用科学算法追踪习惯（参考 Loop Habit Tracker 的健康度模型）。

目前仓库是一个**可运行的 UI 原型**：专注计时、种树动画、习惯健康度算法已经写成真实代码；但习惯列表、森林统计、长期计划、个人中心等页面暂时使用**模拟数据**，尚未接入本地数据库，App 锁定、间隔复习、积分商店等模块**尚未开始实现**。

本 README 如实反映现状，避免夸大。

## 功能现状

| 模块 | 状态 | 说明 |
|------|------|------|
| 番茄钟计时 | 已实现 | `FocusTimerService` 用 Ticker 做 vsync 同步计时，支持 15/25/30/45/60 分钟预设与休息 |
| Flowmodoro 注意力标记 | 已实现 | 运行中可标记 深度专注 / 专注 / 走神 / 分心，分心累计触发中断 |
| 种树动画 + 倒计时环 | 已实现 | `TreeWidget`、`CountdownRing` 用 `CustomPainter` 绘制，无需图片资源 |
| 种树引擎（数据模型） | 已实现 | `Tree` 模型含 8 种树型 × 7 个生长阶段、积分计算与 JSON 序列化 |
| 习惯健康度算法 | 已实现 | `Habit` 模型含 Loop-Habit 式健康度评分（近期 70% + 历史 30%）与微习惯阶梯 |
| 习惯打卡页面 | 原型（模拟数据） | UI 完整，但数据硬编码，未接入持久化 |
| 我的森林 / 统计 / 成就 | 原型（模拟数据） | 统计与成就为写死示例 |
| 长期计划页面 | 原型（无数据模型） | 硬编码目标树示例，暂无 `goal` 模型与持久化 |
| 本地数据库（Drift/SQLite） | 未实现 | `pubspec.yaml` 已声明依赖，但尚无数据库代码 |
| App 锁定 | 未实现 | 仅个人中心有入口占位，无 `app_lock_service` |
| 间隔复习（SM-2） | 未实现 | 无 `spaced_repetition` 服务 |
| 积分商店 | 未实现 | 积分仅在模型中定义，无兑换逻辑 |
| 通知 / 后台计时 | 未实现 | 无 `notification_service`、未接入 WorkManager |
| 知识库同步 | 未实现 | 无网络同步实现 |

## 技术栈

```
Flutter 3.x + Dart 3.x
├── flutter_riverpod   — 状态管理（部分页面已用 StateProvider）
├── drift (SQLite)     — 本地持久化（已声明，尚未接入）
├── CustomPainter      — 种树动画 + 倒计时环
├── Ticker             — vsync 同步精确计时
├── fl_chart           — 个人中心统计图表
└── workmanager / accessibility_service — 后台计时与 App 锁定（已声明，未实现）
```

> 说明：`pubspec.yaml` 中声明了 `assets/trees/`、`assets/animations/`、`assets/sounds/`
> 三个资源目录，但仓库目前**未包含任何资源文件**；种树与倒计时均由代码绘制，因此原型
> 无需图片资源即可运行。后续接入真实资源时再补充。

## 学习来源

| 仓库 / 项目 | 借鉴点 |
|-------------|--------|
| 专注森林 Flutter 版 | 树型设计、生长动画、`CustomPainter` |
| focus-timer | `requestAnimationFrame` 式精确定时、倒计时环思路 |
| Loop Habit Tracker | 健康度算法、热力图、习惯数据模型 |
| MasteryTrack | App 白名单 / 黑名单、空闲检测（规划中） |
| LifeOps | 目标分解树、身份驱动习惯（规划中） |
| LifeHabit | 微习惯阶梯、奖励机制（规划中） |

## 项目结构（当前真实文件）

```
lib/
├── main.dart                  ← App 入口 + Material Design 3 主题 + 底部导航
├── models/
│   ├── timer_session.dart     ← 番茄钟会话模型
│   ├── tree.dart              ← 种树引擎（8 树型 × 7 阶段、积分）
│   └── habit.dart             ← 习惯追踪（健康度算法、微习惯阶梯）
├── services/
│   └── timer_service.dart     ← 计时器核心（Ticker vsync、Flowmodoro）
├── screens/
│   ├── focus_screen.dart      ← 专注种树主页（功能可用）
│   ├── habits_screen.dart     ← 习惯打卡 + 热力图（模拟数据）
│   ├── plan_screen.dart       ← 长期计划（硬编码示例）
│   ├── forest_screen.dart     ← 我的森林（模拟数据）
│   └── profile_screen.dart    ← 统计 + 设置入口（模拟数据）
└── widgets/
    ├── countdown_ring.dart    ← 倒计时环
    └── tree_widget.dart       ← 种树动画组件
```

> 注：原设计中规划的 `providers/`、`services/notification_service.dart`、
> `services/app_lock_service.dart`、`services/spaced_repetition.dart`、
> `models/goal.dart` 等文件**尚未创建**。

## 运行

```bash
# 1. 安装 Flutter SDK（https://docs.flutter.dev/get-started/install）
# 2. 获取依赖
flutter pub get
# 3. 运行（当前为原型，使用模拟数据）
flutter run
```

环境要求：Flutter 3.x、Dart 3.x；专注计时与种树动画在桌面 / 移动模拟器均可预览。

## 开发路线图

- [x] 项目骨架 + 专注计时引擎 + 种树动画
- [x] 种树引擎数据模型（树型 / 阶段 / 积分）
- [x] 习惯健康度算法 + 微习惯阶梯模型
- [ ] 接入 Drift/SQLite，替换各页面模拟数据为真实持久化
- [ ] 习惯打卡真实读写 + 热力图绑定真实数据
- [ ] 长期计划：`goal` 模型与分解树持久化
- [ ] 积分商店：种树得积分 → 解锁树种 / 主题
- [ ] App 锁定：专注模式锁定 + 白名单 + 紧急解锁（Android AccessibilityService）
- [ ] 间隔复习：SM-2 算法自动排期
- [ ] 通知 / 后台计时（WorkManager）+ 知识库同步
- [ ] 补充资源（树图、动画、音效）并打磨 UI，打包发布

## License

MIT
