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

public struct CameraPickerView: UIViewControllerRepresentable {
    let store: StoreOf<CameraPickerFeature>
    
    public init(store: StoreOf<CameraPickerFeature>) {
        self.store = store
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = store.sourceType
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let store: StoreOf<CameraPickerFeature>
        
        init(store: StoreOf<CameraPickerFeature>) {
            self.store = store
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            store.send(.user(.cancelButtonTapped))
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                store.send(.user(.saveButtonTapped(image)))
            } else if let image = info[.editedImage] as? UIImage {
                store.send(.user(.saveButtonTapped(image)))
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(store: self.store)
    }
}

#Preview {
    CameraPickerView(store: .init(initialState: .init(), reducer: {
        CameraPickerFeature()
    }))
}
