// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ERC20_Vapor",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        // Web3.swift
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "Web3", "Web3PromiseKit", "Web3ContractABI"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

