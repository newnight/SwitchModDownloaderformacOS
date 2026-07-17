// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwitchModDownloader",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SwitchModDownloader", targets: ["SwitchModDownloader"])
    ],
    targets: [
        .executableTarget(
            name: "SwitchModDownloader",
            path: "SwitchModDownloader",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets.xcassets"),
                .copy("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
