<p align="center">
    <img src="logo.png" width="400" max-width="90%" alt="Mealy" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.3-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://twitter.com/nerdsupremacist">
        <img src="https://img.shields.io/badge/twitter-@nerdsupremacist-blue.svg?style=flat" alt="Twitter: @nerdsupremacist" />
    </a>
</p>

# Mealy

Mealy allows you to write tests for Object Oriented Software in a more intuitive way while covering the most ground possible. 
With Mealy, you define your tests by implementing a State Machine. 
The framework will then traverse all the possible iterations of your state machine and test your classes thoroughly.

## Installation
### Swift Package Manager

You can install Syntax via [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Mealy.git", from: "0.1.0")
    ]
)
```

## Usage

## Contributions
Contributions are welcome and encouraged!

## License
Mealy is available under the MIT license. See the LICENSE file for more info.
