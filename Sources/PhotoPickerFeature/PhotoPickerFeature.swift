//
//  File.swift
//  PhotoPickerFeature
//
//  Created by Ratnesh Jain on 23/05/25.
//

import ComposableArchitecture
import DefaultStorageDirectory
import Foundation
import PhotosUI
import UniformTypeIdentifiers

@Reducer
public struct PhotoPickerFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        let allowMultipleSelection: Bool
        var filter: PHPickerFilter?
        
        public init(allowMultipleSelection: Bool, filter: PHPickerFilter? = .images) {
            self.allowMultipleSelection = allowMultipleSelection
            self.filter = filter
        }
    }
    
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case didPicked([URL])
        }
        
        public enum UserAction: Equatable {
            case cancelButtonTapped
        }
        
        public enum SystemAction: Equatable {
            case didFinishPicking([URL])
            case didPick(result: [PHPickerResult], picker: PHPickerViewController)
        }
        
        case delegate(DelegateAction)
        case user(UserAction)
        case system(SystemAction)
    }
    
    @Dependency(\.defaultStorageDirectory) private var storageDirectory
    @Dependency(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none
                
            case .system(.didPick(let results, let picker)):
                let results = PhotoPickerResultSendable(results: results, storageDirectory: storageDirectory)
                return .run { send in
                    let urls = try await results.allImages()
                    await send(.system(.didFinishPicking(urls)))
                    await picker.dismiss(animated: true)
                }
                
            case .system(.didFinishPicking(let urls)):
                return .run { send in
                    await send(.delegate(.didPicked(urls)))
                    await dismiss()
                }
                
            case .user(.cancelButtonTapped):
                return .run { send in
                    await dismiss()
                }
            }
        }
    }
}

class PhotoPickerResultSendable: @unchecked Sendable {
    let results: [PHPickerResult]
    let storageDirectory: URL
    
    init(results: [PHPickerResult], storageDirectory: URL) {
        self.results = results
        self.storageDirectory = storageDirectory
    }
    
    func allImages() async throws -> [URL] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[URL], Error>) in
            let destinationURL = storageDirectory
            let group = DispatchGroup()
            let urls = LockIsolated([URL]())
            
            for result in results {
                group.enter()
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    defer { group.leave() }
                    if let url {
                        do {
                            let outputURL = destinationURL.appending(path: url.lastPathComponent)
                            try? FileManager.default.removeItem(at: outputURL)
                            try FileManager.default.moveItem(at: url, to: outputURL)
                            urls.withValue({$0.append(outputURL)})
                        } catch {
                            reportIssue(error)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                continuation.resume(returning: urls.value)
            }
        }
    }
}


