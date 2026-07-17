# Switch Mod Downloader for macOS

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)

专为 macOS 打造的原生应用，用于从 GameBanana 下载 Nintendo Switch 游戏模组。采用现代 SwiftUI 界面，为 Mac 用户提供流畅体验。

**[English](README.md)**

---

## 功能特性

- 🎮 **游戏浏览** - 从 GameBanana 搜索和浏览游戏
- 📦 **模组发现** - 浏览模组，支持分类过滤、关键词搜索和排序
- 📥 **下载管理** - 下载模组文件，支持进度跟踪和历史记录
- 💾 **缓存系统** - 高效缓存以提升性能
- 🖥️ **macOS 原生** - 专为 macOS 设计，拥有原生外观和体验
- 🎨 **SwiftUI 界面** - 使用 SwiftUI 构建现代界面，流畅的 Mac 体验
- ⚡ **现代架构** - MVVM 模式配合 async/await，响应迅速

---

## 截图

> 截图即将添加

---

## 系统要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本（用于从源码构建）

---

## 安装

### 下载安装

从 [Releases](../../releases) 页面下载最新版本。

### 从源码构建

1. 克隆仓库：
   ```bash
   git clone https://github.com/newnight/switch-mod-downloader.git
   cd switch-mod-downloader
   ```

2. 构建应用：
   ```bash
   cd SwitchModDownloader
   ./build.sh
   ```

3. 构建完成的应用程序位于 `dist/` 目录。

---

## 使用方法

1. 启动 **Switch Mod Downloader for macOS**
2. 使用搜索栏搜索游戏
3. 浏览所选游戏的可用模组
4. 点击模组查看详情
5. 下载所需的模组文件
6. 在历史记录标签页查看下载历史

---

## 技术栈

- **编程语言**: Swift 5.9
- **UI 框架**: SwiftUI
- **架构模式**: MVVM (Model-View-ViewModel)
- **并发模型**: Swift Concurrency (async/await)
- **包管理器**: Swift Package Manager
- **数据源**: [GameBanana API](https://gamebanana.com/)
- **最低部署版本**: macOS 13.0

---

## 项目结构

```
SwitchModDownloader/
├── App.swift                    # 应用程序入口
├── Views/                       # SwiftUI 视图
│   ├── ContentView.swift
│   ├── GameListView.swift
│   ├── ModListView.swift
│   ├── ModDetailView.swift
│   ├── SearchView.swift
│   ├── SettingsView.swift
│   └── Components/              # 可复用 UI 组件
├── ViewModels/                  # 业务逻辑和状态管理
│   ├── SearchViewModel.swift
│   ├── ModListViewModel.swift
│   ├── ModDetailViewModel.swift
│   ├── DownloadViewModel.swift
│   └── SettingsViewModel.swift
├── Models/                      # 数据模型
│   ├── Game.swift
│   ├── Mod.swift
│   ├── File.swift
│   ├── Category.swift
│   └── GameBanana/              # API 响应模型
├── Services/                    # 业务服务
│   ├── SearchService.swift
│   ├── ModService.swift
│   ├── DownloadService.swift
│   └── ConfigurationService.swift
├── DataSource/                  # 数据源抽象层
│   ├── ModDataSource.swift
│   ├── GameBananaDataSource.swift
│   └── DataSourceManager.swift
├── Storage/                     # 持久化层
│   ├── DownloadManager.swift
│   ├── DownloadHistoryManager.swift
│   ├── CacheManager.swift
│   └── ConfigurationStore.swift
├── Network/                     # 网络层
│   └── HTTPClient.swift
├── Utilities/                   # 工具类
│   ├── AppLogger.swift
│   └── RetryPolicy.swift
└── Resources/                   # 本地化和资源
    ├── en.lproj/
    └── zh-Hans.lproj/
```

---

## 架构设计

应用程序采用清晰的分层架构：

1. **视图层 (View Layer)** - SwiftUI 视图，负责用户界面
2. **视图模型层 (ViewModel Layer)** - 状态管理和业务逻辑
3. **服务层 (Service Layer)** - 领域特定的业务操作
4. **数据源层 (Data Source Layer)** - 抽象的数据获取（可扩展至其他平台）
5. **存储层 (Storage Layer)** - 持久化和缓存
6. **网络层 (Network Layer)** - HTTP 通信

---

## 配置

应用程序将配置存储在：
- `~/Library/Application Support/SwitchModDownloader/`

您可以自定义：
- 下载位置
- 缓存设置
- 语言偏好

---

## 参与贡献

欢迎贡献代码！请随时提交 Pull Request。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

---

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

---

## 致谢

本项目参考并受 [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) 启发开发。

特别感谢：

- **[PoloNX](https://github.com/PoloNX)** 提供了 [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) - 启发本 macOS 版本的原创 Switch 自制程序模组下载器
- **[GameBanana](https://gamebanana.com/)** 提供了全面的模组数据库和 API
- **Apple** 提供了 SwiftUI 和现代 Swift 并发模型

---

## 支持

如果您遇到任何问题或有功能建议，请[提交 Issue](../../issues/new)。

---

## 相关项目

- [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) - 原版 Switch 自制程序