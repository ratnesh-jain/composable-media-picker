//
//  PhotoPickerView.swift
//  ComposableMediaPicker
//
//  Created by Ratnesh Jain on 23/05/25.
//

#if os(iOS)
import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

/// SwiftUI wrapper for `PHPickerViewController`.
public struct PhotoPickerView: UIViewControllerRepresentable {
    let store: StoreOf<PhotoPickerFeature>
    
    /// Accepts a `PhotoPickerFeature` store.
    public init(store: StoreOf<PhotoPickerFeature>) {
        self.store = store
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = store.selection.limit
        configuration.filter = store.filter
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(store: self.store)
    }
    
    final public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let store: StoreOf<PhotoPickerFeature>
        
        init(store: StoreOf<PhotoPickerFeature>) {
            self.store = store
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            store.send(.system(.didPick(result: results)))
        }
        
        public func pickerDidCancel(_ picker: PHPickerViewController) {
            store.send(.user(.cancelButtonTapped))
            picker.dismiss(animated: true)
        }
    }
}
#endif
