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
                        .copy("Resources/stylesheets/default-iOS"),
                        .copy("Resources/stylesheets/fontawesome.css"),
                        .copy("Resources/stylesheets/katexStyle.css"),
                        .copy("Resources/stylesheets/katexScript.js"),
                        .copy("Resources/stylesheets/texmathStyle.css"),
                        .copy("Resources/stylesheets/texmathScript.js")]
        ),
    ]
)
