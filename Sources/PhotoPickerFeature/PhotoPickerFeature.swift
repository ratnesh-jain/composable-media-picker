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

/// Photo Picker Feature for selecting the images from the Photo's App.
@Reducer
public struct PhotoPickerFeature: Sendable {
    
    /// Image Selection option.
    ///
    /// **Note**: Please use `multiple(limit: 0)` for no limit selection.
    public enum Selection: Equatable, Sendable {
        case single
        case multiple(limit: Int)
        
        var limit: Int {
            switch self {
            case .single:
                return 1
            case .multiple(let limit):
                return limit
            }
        }
    }
    
    /// Single source of truth for the UI State.
    @ObservableState
    public struct State: Equatable {
        let selection: Selection
        var filter: PHPickerFilter?
        
        public init(selection: Selection, filter: PHPickerFilter? = .images) {
            self.selection = selection
            self.filter = filter
        }
    }
    
    /// Declaration of Action Performed by User, System Events and Delegate calls.
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case didPicked([URL])
        }
        
        public enum UserAction: Equatable {
            case cancelButtonTapped
        }
        
        public enum SystemAction: Equatable {
            case didFinishPicking([URL])
            case didPick(result: [PHPickerResult])
        }
        
        case delegate(DelegateAction)
        case user(UserAction)
        case system(SystemAction)
    }
    
    @Dependency(\.defaultStorageDirectory) private var storageDirectory
    @Dependency(\.dismiss) private var dismiss
    
    public init() {}
    
    /// Performs the business logic for defined `Actions`.
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none
                
            case .system(.didPick(let results)):
                let results = PhotoPickerResultSendable(results: results, storageDirectory: storageDirectory)
                return .run { send in
                    let urls = try await results.allImages()
                    await send(.system(.didFinishPicking(urls)))
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

/// Since `PHPickerResult` is not yet sendable so ignoring the Sendablity check and get all Image output.
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


