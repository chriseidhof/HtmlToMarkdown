// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HtmlToMarkdown",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "HtmlToMarkdown",
            targets: ["HtmlToMarkdown"]),
        .library(
            name: "HtmlToMarkdownLib",
            targets: ["HtmlToMarkdownLib"]),
    ],
    dependencies: [
        .package(name: "CommonMark", url: "https://github.com/chriseidhof/commonmark-swift/", .branch("embed-c")),
    ],
    targets: [
        .target(
            name: "HtmlToMarkdown",
            dependencies: ["HtmlToMarkdownLib"]),
        .target(
            name: "HtmlToMarkdownLib",
            dependencies: ["CommonMark"]),
        .testTarget(
            name: "HtmlToMarkdownTests",
            dependencies: ["HtmlToMarkdown"]),
    ]
)
