//
//  File.swift
//  composable-media-picker
//
//  Created by Ratnesh Jain on 24/05/25.
//

import ComposableArchitecture
import Foundation
import VisionKit
import DefaultStorageDirectory

/// A Composable Architecture feature that integrates with `VNDocumentCameraViewController`
/// to scan documents and return either `UIImage`s or local `URL`s pointing to saved images.
@Reducer
public struct DocumentScannerFeature: Sendable {
    
    /// The output type of the document scanner.
    public enum Output: Hashable, Sendable {
        
        /// Return scanned images as `UIImage` array.
        case images
        
        /// Return scanned images as saved local file `URL`s.
        case localURLs
    }
    
    /// The observable state of the feature.
    @ObservableState
    public struct State: Equatable {
        
        /// Determines the output format (images or local URLs).
        var output: Output
        
        /// Initializes the state with a specified output type. Defaults to `.localURLs`.
        public init(output: Output = .localURLs) {
            self.output = output
        }
    }
    
    /// The actions handled by this feature.
    public enum Action: Equatable {
        
        /// Actions that are passed to delegate consumers.
        public enum DelegateAction: Equatable {
            
            /// Delegate received scanned `UIImage`s.
            case didScanImages([UIImage])
            
            /// Delegate received scanned image `URL`s.
            case didScanImagesURLs([URL])
            
            /// Delegate received an error with a message.
            case didReceiveError(message: String)
        }
        
        /// System event driven actions that affect internal logic.
        public enum SystemAction: Equatable {
            
            /// Closes the scanner.
            case close
            
            /// Triggered when scanning is completed with a result.
            case didScan(VNDocumentCameraScan)
            
            /// Triggered when an error occurs.
            case receiveError(String)
        }
        
        /// Action to send a delegate event.
        case delegate(DelegateAction)
        
        /// Action to perform a system event.
        case system(SystemAction)
    }
    
    /// Handles dismissal of the current view.
    @Dependency(\.dismiss) private var dismiss
    
    /// Provides a default storage directory for saving scanned files.
    @Dependency(\.defaultStorageDirectory) private var storageDirectory
    
    /// Provides a UUID generator for naming scanned image files.
    @Dependency(\.uuid) private var uuid
    
    public init() {}
    
    /// Provides a UUID generator for naming scanned image files.
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none
                
            case .system(.close):
                return .run { send in
                    await dismiss()
                }
                
            case .system(.didScan(let scan)):
                var images: [UIImage] = []
                for index in 0..<scan.pageCount {
                    images.append(scan.imageOfPage(at: index))
                }
                let result = images
                switch state.output {
                case .images:
                    return .run { send in
                        await send(.delegate(.didScanImages(result)))
                        await dismiss()
                    }
                case .localURLs:
                    return .run { send in
                        let urls = try await withThrowingTaskGroup(of: [URL].self) { group in
                            for image in result {
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
                        await send(.delegate(.didScanImagesURLs(urls)))
                    }
                }
            case .system(.receiveError(let error)):
                return .send(.delegate(.didReceiveError(message: error)))
            }
        }
    }
}

