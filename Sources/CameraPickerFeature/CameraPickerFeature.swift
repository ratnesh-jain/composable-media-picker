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

@Reducer
public struct CameraPickerFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        let sourceType: UIImagePickerController.SourceType
        let allowsEditing: Bool
        
        public init(sourceType: UIImagePickerController.SourceType = .camera, allowsEditing: Bool = false) {
            self.sourceType = sourceType
            self.allowsEditing = allowsEditing
        }
    }
    
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case didSaveImage(path: String, UIImage)
        }
        
        public enum UserAction: Equatable {
            case cancelButtonTapped
            case saveButtonTapped(UIImage)
        }
        
        case delegate(DelegateAction)
        case user(UserAction)
    }
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.defaultStorageDirectory) private var storageDirectory
    @Dependency(\.uuid) private var uuid
    
    public init() {}
    
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
