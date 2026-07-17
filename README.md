# Switch Mod Downloader for macOS

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)

A native macOS application for downloading Nintendo Switch game mods from GameBanana. Built specifically for Mac users with a modern SwiftUI interface.

**[中文文档](README_zh.md)**

---

## Features

- 🎮 **Game Browsing** - Search and browse games from GameBanana
- 📦 **Mod Discovery** - Browse mods with category filtering, keyword search, and sorting options
- 📥 **Download Management** - Download mod files with progress tracking and history
- 💾 **Cache System** - Efficient caching for improved performance
- 🖥️ **macOS Native** - Designed exclusively for macOS with native look and feel
- 🎨 **SwiftUI Interface** - Modern UI built with SwiftUI for seamless Mac experience
- ⚡ **Modern Architecture** - MVVM pattern with async/await for responsive performance

---

## Screenshots

> Screenshots will be added soon

---

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later (for building from source)

---

## Installation

### Download

Download the latest release from the [Releases](../../releases) page.

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/newnight/switch-mod-downloader.git
   cd switch-mod-downloader
   ```

2. Build the application:
   ```bash
   cd SwitchModDownloader
   ./build.sh
   ```

3. The built application will be in the `dist/` directory.

---

## Usage

1. Launch **Switch Mod Downloader for macOS**
2. Search for a game using the search bar
3. Browse available mods for the selected game
4. Click on a mod to view details
5. Download the mod files you need
6. Access your download history in the History tab

---

## Technical Stack

- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Concurrency**: Swift Concurrency (async/await)
- **Package Manager**: Swift Package Manager
- **Data Source**: [GameBanana API](https://gamebanana.com/)
- **Minimum Deployment**: macOS 13.0

---

## Project Structure

```
SwitchModDownloader/
├── App.swift                    # Application entry point
├── Views/                       # SwiftUI views
│   ├── ContentView.swift
│   ├── GameListView.swift
│   ├── ModListView.swift
│   ├── ModDetailView.swift
│   ├── SearchView.swift
│   ├── SettingsView.swift
│   └── Components/              # Reusable UI components
├── ViewModels/                  # Business logic and state management
│   ├── SearchViewModel.swift
│   ├── ModListViewModel.swift
│   ├── ModDetailViewModel.swift
│   ├── DownloadViewModel.swift
│   └── SettingsViewModel.swift
├── Models/                      # Data models
│   ├── Game.swift
│   ├── Mod.swift
│   ├── File.swift
│   ├── Category.swift
│   └── GameBanana/              # API response models
├── Services/                    # Business services
│   ├── SearchService.swift
│   ├── ModService.swift
│   ├── DownloadService.swift
│   └── ConfigurationService.swift
├── DataSource/                  # Data source abstraction
│   ├── ModDataSource.swift
│   ├── GameBananaDataSource.swift
│   └── DataSourceManager.swift
├── Storage/                     # Persistence layer
│   ├── DownloadManager.swift
│   ├── DownloadHistoryManager.swift
│   ├── CacheManager.swift
│   └── ConfigurationStore.swift
├── Network/                     # Networking layer
│   └── HTTPClient.swift
├── Utilities/                   # Helper utilities
│   ├── AppLogger.swift
│   └── RetryPolicy.swift
└── Resources/                   # Localization and assets
    ├── en.lproj/
    └── zh-Hans.lproj/
```

---

## Architecture

The application follows a clean layered architecture:

1. **View Layer** - SwiftUI views for user interface
2. **ViewModel Layer** - State management and business logic
3. **Service Layer** - Domain-specific business operations
4. **Data Source Layer** - Abstracted data fetching (extensible to other platforms)
5. **Storage Layer** - Persistence and caching
6. **Network Layer** - HTTP communication

---

## Configuration

The application stores configuration in:
- `~/Library/Application Support/SwitchModDownloader/`

You can customize:
- Download location
- Cache settings
- Language preference

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

This project was inspired by and references [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) by PoloNX.

Special thanks to:

- **[PoloNX](https://github.com/PoloNX)** for [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) - the original Switch homebrew mod downloader that inspired this macOS version
- **[GameBanana](https://gamebanana.com/)** for providing the comprehensive mod database and API
- **Apple** for SwiftUI and the modern Swift concurrency model

---

## Support

If you encounter any bugs or have feature requests, please [open an issue](../../issues/new).

---

## Related Projects

- [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) - Original Switch homebrew version