// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SplatWallpaperEngine",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "SplatWallpaperEngine",
            resources: [
                .copy("Renderer")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit")
            ]
        )
    ]
)

