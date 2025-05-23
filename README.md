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
            $0.defaultStorageDirectory = URL.documentsDirectory
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
## Usage:

```swift
import CameraPickerFeature
import ComposableArchitecture
import PhotoPickerFeature

@Reducer
public struct ProfileFormFeature: Sendable {
    
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case camera(CameraPickerFeature)
        case photos(PhotoPickerFeature)
    }

    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        var selectedMedias: [URL] = []
        
        ...
    }
    
    public enum Action: Equatable {
        public enum UserAction: Equatable {
            case cameraButtonTapped
            case photosButtonTapped 
        }
    
        case destination(PresentationAction<Destination.Action>)
        case user(UserAction)
        
        ...
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            case .destination(.presented(.camera(.delegate(.didSaveImage(path: let path, _))))):
                state.selectedMedias.append(URL.documentsDirectory.appending(path: path))
                return .none
                
            case .destination(.presented(.photos(.delegate(.didPicked(let urls))))):
                state.selectedMedias.append(contentsOf: urls)
                return .none
                
            case .destination:
                return .none
            
            case .user(.cameraButtonTapped):
                state.destination = .camera(.init(sourceType: .camera))
                return .none
                
            case .user(.photosButtonTapped):
                state.destination = .photos(.init(allowMultipleSelection: true))
                return .none
                
            ...
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

```
