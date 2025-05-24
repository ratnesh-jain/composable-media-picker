//
//  ComposableMediaPickerStudyApp.swift
//  ComposableMediaPickerStudy
//
//  Created by Ratnesh Jain on 24/05/25.
//

import SwiftUI

@main
struct ComposableMediaPickerStudyApp: App {
    var body: some Scene {
        WindowGroup {
            ProfileFormView(store: .init(initialState: .init(), reducer: {
                ProfileFormFeature()
            }))
        }
    }
}
