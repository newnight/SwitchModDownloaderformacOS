# Changelog

All notable changes to Switch Mod Downloader for macOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Switch Mod Downloader for macOS
- Game browsing and search functionality from GameBanana
- Mod browsing with category filtering, keyword search, and sorting
- Mod detail viewing with file information
- Download management with progress tracking
- Download history tracking
- Cache management system
- Multi-language support (English and Simplified Chinese)
- Native macOS UI built with SwiftUI
- MVVM architecture with async/await
- Support for both Apple Silicon (arm64) and Intel (x86_64) Macs

### Technical Details
- Built with Swift 5.9 and SwiftUI
- Minimum deployment target: macOS 13.0
- Uses GameBanana API v11 for data
- Implements clean layered architecture
- Dependency injection for extensibility

### Acknowledgments
- Inspired by [SimpleModDownloader](https://github.com/PoloNX/SimpleModDownloader) by PoloNX
- Uses [GameBanana API](https://gamebanana.com/) for mod data

[Unreleased]: https://github.com/your-username/switch-mod-downloader/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-username/switch-mod-downloader/releases/tag/v1.0.0