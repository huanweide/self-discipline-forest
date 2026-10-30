**中文** · [README.md](./README.md)

<!-- badges -->
[![License](https://img.shields.io/github/license/huanweide/self-discipline-forest)](LICENSE)
[![CI](https://github.com/huanweide/self-discipline-forest/actions/workflows/ci.yml/badge.svg)](https://github.com/huanweide/self-discipline-forest/actions/workflows/ci.yml)
[![Stars](https://img.shields.io/github/stars/huanweide/self-discipline-forest)](https://github.com/huanweide/self-discipline-forest/stargazers)
<!-- /badges -->

# Self-Discipline Forest

> Plant every focus session as a tree — a Flutter experiment combining a pomodoro timer, gamified tree-growing, and habit tracking.
> Currently a **work-in-progress prototype**: the core timer and data models are in place, but most screens still use mock data.

## Who should use it / Who shouldn't

- **Use it if** you're a developer looking for a Flutter reference implementation of "tree-growing animation / pomodoro / habit-health algorithm"; or a reader interested in self-discipline app prototyping.
- **Skip it if** you want a finished, ready-to-use app (this is a WIP prototype; most screens are still mock data and it has no local database wired up yet).

## Overview

Self-Discipline Forest wants to combine several self-discipline tools into one app: focus with a pomodoro timer, fight distraction with a gamified "plant a tree" mechanic (borrowing Forest's loss-aversion idea), and track habits with a scientific algorithm (borrowing Loop Habit Tracker's health-score model).

The repo is currently a **runnable UI prototype**: the focus timer, tree-growing animation, and habit-health algorithm are real code; but the habit list, forest stats, long-term plan, and profile screens still use **mock data** and aren't persisted yet, and modules like app lock, spaced repetition, and the points shop **haven't been started**.

This README reflects the current state honestly — no overclaiming.

## Feature status

| Module | Status | Description |
|------|------|------|
| Pomodoro timer | Implemented | `FocusTimerService` uses Ticker for vsync-synced timing; presets 15/25/30/45/60 min + breaks |
| Flowmodoro attention mark | Implemented | Mark deep-focus / focus / distracted / off-task during a run; accumulated distraction triggers an interruption |
| Tree animation + countdown ring | Implemented | `TreeWidget`, `CountdownRing` drawn with `CustomPainter`, no image assets needed |
| Tree engine (data model) | Implemented | `Tree` model: 8 tree types × 7 growth stages, point calc, JSON serialization |
| Habit health algorithm | Implemented | `Habit` model: Loop-Habit-style health score (recent 70% + history 30%) + micro-habit ladder |
| Habit check-in screen | Prototype (mock) | UI complete but data hardcoded, not persisted |
| My forest / stats / achievements | Prototype (mock) | Stats and achievements are hardcoded samples |
| Long-term plan screen | Prototype (no model) | Hardcoded goal-tree sample; no `goal` model or persistence yet |
| Local DB (Drift/SQLite) | Not implemented | `pubspec.yaml` declares the dependency, but no DB code yet |
| App lock | Not implemented | Only a placeholder entry in profile; no `app_lock_service` |
| Spaced repetition (SM-2) | Not implemented | No `spaced_repetition` service |
| Points shop | Not implemented | Points defined only in the model, no redeem logic |
| Notifications / background timer | Not implemented | No `notification_service`, no WorkManager |
| Knowledge-base sync | Not implemented | No network sync implementation |

## Tech stack

```
Flutter 3.x + Dart 3.x
├── flutter_riverpod   — state management (StateProvider on some screens)
├── drift (SQLite)     — local persistence (declared, not wired up)
├── CustomPainter      — tree animation + countdown ring
├── Ticker             — vsync-synced precise timing
├── fl_chart           — profile stats charts
└── workmanager / accessibility_service — background timer & app lock (declared, not implemented)
```

> Note: `pubspec.yaml` declares three asset dirs — `assets/trees/`, `assets/animations/`, `assets/sounds/` — but the repo currently **contains no asset files**. Trees and the countdown ring are drawn in code, so the prototype runs without image assets. Real assets will be added later.

## Learning sources

| Repo / project | Borrowed from |
|-------------|--------|
| Focus Forest (Flutter) | tree design, growth animation, `CustomPainter` |
| focus-timer | `requestAnimationFrame`-style precise timing, countdown ring idea |
| Loop Habit Tracker | health-score algorithm, heatmap, habit data model |
| MasteryTrack | app whitelist / blacklist, idle detection (planned) |
| LifeOps | goal-decomposition tree, identity-driven habits (planned) |
| LifeHabit | micro-habit ladder, reward mechanism (planned) |

## Project structure (current real files)

```
lib/
├── main.dart                  ← App entry + Material Design 3 theme + bottom nav
├── models/
│   ├── timer_session.dart     ← pomodoro session model
│   ├── tree.dart              ← tree engine (8 types × 7 stages, points)
│   └── habit.dart             ← habit tracking (health algorithm, micro-habit ladder)
├── services/
│   └── timer_service.dart     ← timer core (Ticker vsync, Flowmodoro)
├── screens/
│   ├── focus_screen.dart      ← focus + tree home (functional)
│   ├── habits_screen.dart     ← habit check-in + heatmap (mock data)
│   ├── plan_screen.dart       ← long-term plan (hardcoded sample)
│   ├── forest_screen.dart     ← my forest (mock data)
│   └── profile_screen.dart    ← stats + settings entry (mock data)
└── widgets/
    ├── countdown_ring.dart    ← countdown ring
    └── tree_widget.dart       ← tree animation widget
```

> Note: planned files `providers/`, `services/notification_service.dart`, `services/app_lock_service.dart`, `services/spaced_repetition.dart`, `models/goal.dart` are **not created yet**.

## Run

```bash
# 1. Install the Flutter SDK (https://docs.flutter.dev/get-started/install)
# 2. Fetch dependencies
flutter pub get
# 3. Run (currently a prototype using mock data)
flutter run
```

Requirements: Flutter 3.x, Dart 3.x. The focus timer and tree animation preview on desktop / mobile emulators.

## Roadmap

- [x] Project skeleton + focus-timer engine + tree animation
- [x] Tree-engine data model (types / stages / points)
- [x] Habit-health algorithm + micro-habit ladder model
- [ ] Wire up Drift/SQLite, replace mock data with real persistence
- [ ] Real habit check-in read/write + heatmap bound to real data
- [ ] Long-term plan: `goal` model and decomposition-tree persistence
- [ ] Points shop: plant → earn points → unlock tree types / themes
- [ ] App lock: focus-mode lock + whitelist + emergency unlock (Android AccessibilityService)
- [ ] Spaced repetition: SM-2 auto-scheduling
- [ ] Notifications / background timer (WorkManager) + knowledge-base sync
- [ ] Add assets (tree art, animations, sounds) and polish UI, then package & release

## Contributing

This is an early prototype. Issues and PRs are welcome, especially around persistence (Drift) and the not-yet-built modules.

## ⭐ Star

If this Flutter tree / pomodoro / habit-algorithm prototype inspires you, a Star ⭐ helps others find it: https://github.com/huanweide/self-discipline-forest

## Author

[huanweide](https://github.com/huanweide)

## License

MIT
