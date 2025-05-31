//
//  File.swift
//  ComposableMediaPicker
//
//  Created by Ratnesh Jain on 23/05/25.
//

import Dependencies
import DependenciesMacros
import Foundation

/// A `DependencyKey` for providing a default directory URL used for storing files,
/// typically the app's documents directory.
public struct DefaultStorageDirectory: DependencyKey {
    
    /// The default live value for the dependency, pointing to the app’s Documents directory.
    public static var liveValue: URL {
        URL.documentsDirectory
    }
}

/// An extension to `DependencyValues` for accessing and setting the default storage directory.
///
/// This allows injecting a custom directory (e.g., for testing or preview environment)
extension DependencyValues {
    public var defaultStorageDirectory: URL {
        get { self[DefaultStorageDirectory.self] }
        set { self[DefaultStorageDirectory.self] = newValue }
    }
}
