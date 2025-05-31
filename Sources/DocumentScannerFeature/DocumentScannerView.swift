//
//  File.swift
//  composable-media-picker
//
//  Created by Ratnesh Jain on 24/05/25.
//

#if os(iOS)
import ComposableArchitecture
import Foundation
import VisionKit
import SwiftUI

/// A SwiftUI-compatible wrapper for `VNDocumentCameraViewController`
/// that integrates with a `DocumentScannerFeature` store from Composable Architecture.
public struct DocumentScannerView: UIViewControllerRepresentable {
    
    /// The store backing the `DocumentScannerFeature`.
    let store: StoreOf<DocumentScannerFeature>
    
    /// Initializes the view with a given `DocumentScannerFeature` store.
    ///
    /// - Parameter store: The `StoreOf<DocumentScannerFeature>` managing state and actions.
    public init(store: StoreOf<DocumentScannerFeature>) {
        self.store = store
    }
    
    /// Creates the `VNDocumentCameraViewController` used for scanning documents.
    ///
    /// - Parameter context: The context provided by SwiftUI.
    /// - Returns: A configured `VNDocumentCameraViewController` instance.
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    /// Updates the view controller when the SwiftUI view changes.
    ///
    /// Not used in this case because the scanner UI does not require live updates.
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    /// The coordinator that acts as the delegate for `VNDocumentCameraViewController`.
    /// It connects UIKit events back to the Composable Architecture store.
    public class Coordinator: NSObject, @preconcurrency VNDocumentCameraViewControllerDelegate {
        
        /// The store managing the scanner feature state and logic.
        let store: StoreOf<DocumentScannerFeature>
        
        /// Initializes the coordinator with the feature store.
        ///
        /// - Parameter store: The TCA store to which actions are dispatched.
        init(store: StoreOf<DocumentScannerFeature>) {
            self.store = store
        }
        
        /// Called when the user cancels the document scanning.
        ///
        /// - Parameter controller: The camera view controller.
        @MainActor public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            store.send(.system(.close))
        }
        
        /// Called when the user finishes scanning documents.
        ///
        /// - Parameters:
        ///   - controller: The camera view controller.
        ///   - scan: The scan result containing pages as images.
        @MainActor public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            store.send(.system(.didScan(scan)))
        }
        
        /// Called when an error occurs during document scanning.
        ///
        /// - Parameters:
        ///   - controller: The camera view controller.
        ///   - error: The error encountered.
        @MainActor public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            store.send(.system(.receiveError(error.localizedDescription)))
        }
    }
    
    /// Creates the coordinator that handles delegate callbacks.
    ///
    /// - Returns: An instance of `Coordinator`.
    public func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }
}
#endif
