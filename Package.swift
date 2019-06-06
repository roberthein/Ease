// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Ease",
    products: [
        .library(name: "Ease", targets: ["Ease"])
    ],
    targets: [
        .target(name: "Ease", path: "Ease/Classes")
    ]
)
