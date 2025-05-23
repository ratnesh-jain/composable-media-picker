#  Composable Media Picker

This package encapsulate media picker such as Camera Picker and Photos Picker for iOS Composable Architecture based projects.

## Installation

```swift
dependencies: [
  .package(url: "https://github.com/ratnesh-jain/composable-media-picker", .upToNextMajor("0.1.0")
]
```

## Compatibility

- Swift 6.1
- iOS 17+

## Package Libraries

- DefaultStorageDirectory
- CameraPickerFeature
- PhotoPickerFeature

## Configuration

```swift
import DefaultStorageDirectory
import ImageDownloader
import SwiftUI

@Main
struct MainApp: App {
    init() {
        prepareDependencies {
            $0.defaultStorageDirectory = { URL.documentsDirectory }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
