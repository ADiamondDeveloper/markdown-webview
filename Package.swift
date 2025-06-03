// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "markdown-webview",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "MarkdownWebView",
            targets: ["MarkdownWebView"]
        ),
    ],
    targets: [
        .target(
            name: "MarkdownWebView",
            resources: [.copy("Resources/template"),
                        .copy("Resources/script"),
                        .copy("Resources/stylesheets/default-iOS")]
        ),
    ]
)
