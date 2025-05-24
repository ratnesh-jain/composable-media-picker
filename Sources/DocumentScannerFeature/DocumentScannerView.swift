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

public struct DocumentScannerView: UIViewControllerRepresentable {
    let store: StoreOf<DocumentScannerFeature>
    
    public init(store: StoreOf<DocumentScannerFeature>) {
        self.store = store
    }
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    public class Coordinator: NSObject, @preconcurrency VNDocumentCameraViewControllerDelegate {
        let store: StoreOf<DocumentScannerFeature>
        init(store: StoreOf<DocumentScannerFeature>) {
            self.store = store
        }
        
        @MainActor public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            store.send(.system(.close))
        }
        
        @MainActor public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            store.send(.system(.didScan(scan)))
        }
        
        @MainActor public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
            store.send(.system(.receiveError(error.localizedDescription)))
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }
}
#endif
