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
                print("received images: \(images)")
                return .none
                
            case .destination(.presented(.scanner(.delegate(.didScanImagesURLs(let urls))))):
                return .send(.system(.didReceiveScannedImages(urls)))
                
            case .destination:
                return .none
                
            case .system(.didReceiveScannedImages(let urls)):
                state.selectedMedias.append(contentsOf: urls)
                return .none
                
            case .user(.cameraButtonTapped):
                state.destination = .camera(.init())
                return .none
                
            case .user(.photoButtonTapped):
                state.destination = .photo(.init(selection: .multiple(limit: 0)))
                return .none
                
            case .user(.scannerButtonTapped):
                state.destination = .scanner(.init(output: .localURLs))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
