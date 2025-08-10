// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ShoppingListPackage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ShoppingList",
            targets: ["ShoppingList"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing", from: "0.8.1")
    ],
    targets: [
        .target(
            name: "ShoppingList",
            dependencies: [],
            path: "Sources/ShoppingList"
        )
    ]
)
