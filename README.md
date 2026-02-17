# 六家统 Flutter 客户端

六家统（LiuJiaTong）的 Flutter 客户端，一套代码支持 Android、iOS、Web、Windows、macOS、Linux。

## 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.11.0 或更高版本（含对应平台工具链）
- **Windows 桌面**：需安装 [Visual Studio](https://visualstudio.microsoft.com/) 并勾选「使用 C++ 的桌面开发」
- **macOS 桌面**：Xcode 命令行工具
- **Linux 桌面**：clang、GTK 等（见 [Flutter 文档](https://docs.flutter.dev/get-started/install/linux)）

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行应用（自动选择可用设备）
flutter run

# 查看已连接设备
flutter devices
```

### 指定平台运行

```bash
# Web（Chrome）
flutter run -d chrome

# Windows 桌面
flutter run -d windows

# Android 模拟器/真机
flutter run -d android

# iOS 模拟器（仅 macOS）
flutter run -d ios

# macOS 桌面（仅 macOS）
flutter run -d macos

# Linux 桌面
flutter run -d linux
```

## 项目结构

项目采用清晰的分层架构设计：

```
lib/
├── main.dart                    # 应用入口
├── application/                 # 应用层：业务逻辑协调
│   ├── game_controller.dart    # 游戏控制器
│   ├── game_login.dart         # 登录逻辑
│   └── play_result.dart        # 出牌结果
├── core/                        # 核心层：领域模型与规则
│   ├── models/                 # 数据模型
│   │   ├── card.dart          # 卡牌模型
│   │   ├── config.dart        # 配置模型
│   │   └── field_info.dart    # 场况信息
│   ├── rules/                  # 游戏规则
│   │   └── playing_rules.dart  # 出牌规则判断
│   ├── utils/                  # 工具函数
│   │   └── card_utils.dart    # 卡牌工具
│   └── auto_play/              # 自动托管
│       └── strategy.dart      # 自动出牌策略
├── data/                        # 数据层：数据访问与 IO
│   ├── config/                 # 配置管理
│   │   └── config_repository.dart
│   ├── network/                # 网络通信
│   │   ├── socket_client.dart
│   │   ├── socket_client_io.dart
│   │   ├── socket_client_stub.dart
│   │   └── protocol.dart
│   ├── sound/                   # 音效服务
│   │   └── sound_service.dart
│   └── logger.dart             # 日志服务
└── presentation/                # 展示层：UI 界面
    └── screens/                 # 页面
        ├── login_screen.dart   # 登录页
        ├── lobby_screen.dart   # 大厅页
        └── game_screen.dart    # 游戏页
```

### 其他目录

- `assets/` — 资源文件（图片、音效、字体）
- `docs/` — 项目文档
  - `protocol.md`` — 网络协议文档
  - `game_rules.md` — 游戏规则说明
  - `auto_play_strategy.md` — 自动托管策略
  - `project_structure.md` — 项目结构详细说明
- `test/` — 单元测试与 Widget 测试
- `android/`, `ios/`, `windows/`, `macos/`, `linux/`, `web/` — 各平台原生配置

## 依赖说明

主要依赖包：

- `audioplayers: ^6.0.0` — 音效播放
- `path_provider: ^2.1.0` — 文件路径管理
- `cupertino_icons: ^1.0.8` — iOS 风格图标

## 文档

详细文档请查看 `docs/` 目录：

- [网络协议](docs/protocol.md) — 客户端与服务器通信协议
- [游戏规则](docs/game_rules.md) — 六家统游戏规则说明
- [自动托管策略](docs/auto_play_strategy.md) — AI 自动出牌策略
- [项目结构](docs/project_structure.md) — 项目架构与依赖关系图
