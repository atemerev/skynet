import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/Zewo/System.git", majorVersion: 0, minor: 2)
    ]
)
