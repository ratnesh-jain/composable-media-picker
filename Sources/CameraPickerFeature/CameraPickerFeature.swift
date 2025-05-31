//
//  File.swift
//  ComposableMediaPicker
//
//  Created by Ratnesh Jain on 23/05/25.
//

#if os(iOS)
import ComposableArchitecture
import DefaultStorageDirectory
import Foundation
import UIKit

/// A `Reducer` feature using The Composable Architecture (TCA) for managing camera-based image picking.
/// It handles capturing an image using `UIImagePickerController` and saving the result to disk.
@Reducer
public struct CameraPickerFeature: Sendable {
    
    /// The observable state for the camera picker feature.
    @ObservableState
    public struct State: Equatable {
        
        /// Specifies the source type (e.g., `.camera`, `.photoLibrary`).
        let sourceType: UIImagePickerController.SourceType
        
        /// Indicates whether image editing is allowed after picking.
        let allowsEditing: Bool
        
        /// Initializes the state.
        ///
        /// - Parameters:
        ///   - sourceType: The source for image picking. Default is `.camera`.
        ///   - allowsEditing: Whether editing is allowed. Default is `false`.
        public init(sourceType: UIImagePickerController.SourceType = .camera, allowsEditing: Bool = false) {
            self.sourceType = sourceType
            self.allowsEditing = allowsEditing
        }
    }
    
    /// Actions handled by the camera picker feature.
    public enum Action: Equatable {
        
        /// Delegate actions to inform external consumers of side effects or results.
        public enum DelegateAction: Equatable {
            
            /// Called when an image is saved with its local file path and `UIImage`.
            case didSaveImage(path: String, UIImage)
        }
        
        /// Actions initiated by the user through the UI.
        public enum UserAction: Equatable {
            
            /// Called when the user taps the cancel button.
            case cancelButtonTapped
            
            /// Called when the user accepts an image and wants to save it.
            case saveButtonTapped(UIImage)
        }
        
        /// Wraps a delegate action.
        case delegate(DelegateAction)
        
        /// Wraps a user-initiated action.
        case user(UserAction)
    }
    
    /// Handles view dismissal.
    @Dependency(\.dismiss) private var dismiss
    
    /// Provides a writable storage directory.
    @Dependency(\.defaultStorageDirectory) private var storageDirectory
    
    /// Provides a UUID generator for naming saved image files.
    @Dependency(\.uuid) private var uuid
    
    public init() {}
    
    /// The body of the reducer handling side effects and actions.
    public var body: some ReducerOf<Self> {
        EmptyReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none
                
            case .user(.cancelButtonTapped):
                return .run { send in
                    await dismiss()
                }
                
            case .user(.saveButtonTapped(let image)):
                guard let data = image.jpegData(compressionQuality: 0.1) else { return .none }
                let url = storageDirectory.appending(path: "\(uuid().uuidString).png")
                let path = url.lastPathComponent
                return .run { send in
                    try data.write(to: url)
                    await send(.delegate(.didSaveImage(path: path, image)))
                    await dismiss()
                }
            }
        }
    }
}
#endif
