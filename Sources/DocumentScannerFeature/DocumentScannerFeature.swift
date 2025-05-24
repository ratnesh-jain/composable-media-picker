//
//  File.swift
//  composable-media-picker
//
//  Created by Ratnesh Jain on 24/05/25.
//

import ComposableArchitecture
import Foundation
import VisionKit

@Reducer
public struct DocumentScannerFeature: Sendable {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case didScanImages([UIImage])
            case didReceiveError(message: String)
        }
        
        public enum SystemAction: Equatable {
            case close
            case didScan(VNDocumentCameraScan)
            case receiveError(String)
        }
        
        case delegate(DelegateAction)
        case system(SystemAction)
    }
    
    @Dependency(\.dismiss) private var dismiss
    
    public init() {}
    
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
                return .run { send in
                    await send(.delegate(.didScanImages(result)))
                    await dismiss()
                }
                
            case .system(.receiveError(let error)):
                return .send(.delegate(.didReceiveError(message: error)))
            }
        }
    }
}

