//
//  ProfileFormFeature.swift
//  ComposableMediaPickerStudy
//
//  Created by Ratnesh Jain on 24/05/25.
//

import CameraPickerFeature
import ComposableArchitecture
import DocumentScannerFeature
import Foundation
import PhotoPickerFeature

@Reducer
struct ProfileFormFeature {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case camera(CameraPickerFeature)
        case photo(PhotoPickerFeature)
        case scanner(DocumentScannerFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var selectedMedias: [URL] = []
        @Presents var destination: Destination.State?
    }
    
    enum Action: Equatable {
        enum SystemAction: Equatable {
            case didReceiveScannedImages([URL])
        }
        
        enum UserAction: Equatable {
            case cameraButtonTapped
            case photoButtonTapped
            case scannerButtonTapped
        }
        case destination(PresentationAction<Destination.Action>)
        case system(SystemAction)
        case user(UserAction)
    }
    
    @Dependency(\.defaultStorageDirectory) var storageDirectory
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination(.presented(.camera(.delegate(.didSaveImage(path: let path, _))))):
                state.selectedMedias.append(URL.documentsDirectory.appending(path: path))
                return .none
                
            case .destination(.presented(.photo(.delegate(.didPicked(let urls))))):
                state.selectedMedias.append(contentsOf: urls)
                return .none
                
            case .destination(.presented(.scanner(.delegate(.didScanImages(let images))))):
                return .run { send in
                    let urls = try await withThrowingTaskGroup(of: [URL].self) { group in
                        for image in images {
                            group.addTask {
                                let destinationURL = storageDirectory.appending(path: uuid().uuidString.appending(".png"))
                                try image.pngData()?.write(to: destinationURL)
                                return [destinationURL]
                            }
                        }
                        var urls: [URL] = []
                        for try await url in group {
                            urls.append(contentsOf: url)
                        }
                        return urls
                    }
                    await send(.system(.didReceiveScannedImages(urls)))
                }
                
            case .destination:
                return .none
                
            case .system(.didReceiveScannedImages(let urls)):
                state.selectedMedias.append(contentsOf: urls)
                return .none
                
            case .user(.cameraButtonTapped):
                state.destination = .camera(.init())
                return .none
                
            case .user(.photoButtonTapped):
                state.destination = .photo(.init(allowMultipleSelection: true))
                return .none
                
            case .user(.scannerButtonTapped):
                state.destination = .scanner(.init())
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
