//
//  ProfileFormView.swift
//  ComposableMediaPickerStudy
//
//  Created by Ratnesh Jain on 24/05/25.
//

import AppAsyncImage
import CameraPickerFeature
import ComposableArchitecture
import DocumentScannerFeature
import Foundation
import PhotoPickerFeature
import SwiftUI

struct ProfileFormView: View {
    @Bindable var store: StoreOf<ProfileFormFeature>
    
    init(store: StoreOf<ProfileFormFeature>) {
        self.store = store
    }
    
    var body: some View {
        Form {
            Section {
                if store.selectedMedias.isEmpty {
                    ContentUnavailableView("No Selected Media", systemImage: "photo", description: Text("Use below media buttons to import."))
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100)), GridItem(.adaptive(minimum: 100))]) {
                        ForEach(store.selectedMedias, id: \.self) { media in
                            AppAsyncImage(url: media)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: 12))
                                .frame(height: 240)
                        }
                    }
                }
            } header: {
                Text("Selected Medias")
            }
        }
        .sheet(item: $store.scope(state: \.destination, action: \.destination)) { destinationStore in
            DestinationView(store: destinationStore)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button("Import from Camera", systemImage: "camera") {
                    store.send(.user(.cameraButtonTapped))
                }
                Divider()
                Button("Import from Photos", systemImage: "photo") {
                    store.send(.user(.photoButtonTapped))
                }
                Divider()
                Button("Scan Document", systemImage: "viewfinder") {
                    store.send(.user(.scannerButtonTapped))
                }
            }
            .font(.title3)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Material.bar)
        }
    }
    
    struct DestinationView: View {
        let store: StoreOf<ProfileFormFeature.Destination>
        var body: some View {
            switch store.case {
            case .camera(let cameraStore):
                CameraPickerView(store: cameraStore)
                    .ignoresSafeArea()
                
            case .photo(let photoStore):
                PhotoPickerView(store: photoStore)
                    .ignoresSafeArea()
                
            case .scanner(let scannerStore):
                DocumentScannerView(store: scannerStore)
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ProfileFormView(store: .init(initialState: .init(), reducer: {
        ProfileFormFeature()
    }))
}
