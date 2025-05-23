//
//  File.swift
//  ComposableMediaPicker
//
//  Created by Ratnesh Jain on 23/05/25.
//

import Dependencies
import DependenciesMacros
import Foundation

public struct DefaultStorageDirectory: DependencyKey {
    public static var liveValue: URL {
        URL.documentsDirectory
    }
}

extension DependencyValues {
    public var defaultStorageDirectory: URL {
        get { self[DefaultStorageDirectory.self] }
        set { self[DefaultStorageDirectory.self] = newValue }
    }
}
