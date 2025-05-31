//
//  CameraPickerView.swift
//  ComposableMediaPicker
//
//  Created by Ratnesh Jain on 23/05/25.
//


import ComposableArchitecture
import Foundation
import UIKit
import SwiftUI

/// A SwiftUI-compatible wrapper for `UIImagePickerController`
/// that integrates with a `CameraPickerFeature` store using Composable Architecture.
public struct CameraPickerView: UIViewControllerRepresentable {
    
    /// The TCA store managing state and actions for camera image picking.
    let store: StoreOf<CameraPickerFeature>

    /// Initializes the view with the given store.
    ///
    /// - Parameter store: A `StoreOf<CameraPickerFeature>` instance used to manage feature logic.
    public init(store: StoreOf<CameraPickerFeature>) {
        self.store = store
    }
    
    /// Creates the `UIImagePickerController` used for capturing or selecting images.
    ///
    /// - Parameter context: The context provided by SwiftUI.
    /// - Returns: A configured `UIImagePickerController` instance.
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = store.sourceType
        controller.allowsEditing = store.allowsEditing
        controller.delegate = context.coordinator
        return controller
    }
    
    /// Updates the UIKit controller when SwiftUI's state changes.
    ///
    /// - Parameters:
    ///   - uiViewController: The picker controller to update.
    ///   - context: The SwiftUI context.
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    /// The coordinator acts as a delegate to handle image picker events
    /// and relay them back to the TCA store as actions.
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        /// The store to dispatch actions to.
        let store: StoreOf<CameraPickerFeature>
        
        /// Initializes the coordinator.
        ///
        /// - Parameter store: The feature store.
        init(store: StoreOf<CameraPickerFeature>) {
            self.store = store
        }
        
        /// Called when the user cancels image picking.
        ///
        /// - Parameter picker: The image picker controller.
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            store.send(.user(.cancelButtonTapped))
        }
        
        /// Called when the user picks an image.
        ///
        /// - Parameters:
        ///   - picker: The image picker controller.
        ///   - info: A dictionary containing the original or edited image.
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                store.send(.user(.saveButtonTapped(image)))
            } else if let image = info[.editedImage] as? UIImage {
                store.send(.user(.saveButtonTapped(image)))
            }
        }
    }
    
    /// Creates a coordinator to bridge UIKit delegate methods back to the store.
    ///
    /// - Returns: A `Coordinator` instance.
    public func makeCoordinator() -> Coordinator {
        Coordinator(store: self.store)
    }
}

#Preview {
    CameraPickerView(store: .init(initialState: .init(), reducer: {
        CameraPickerFeature()
    }))
}
