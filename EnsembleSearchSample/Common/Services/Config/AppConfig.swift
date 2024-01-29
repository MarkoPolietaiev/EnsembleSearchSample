//
//  AppConfig.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

/// A utility class for fetching configuration values from the Info.plist file.
class AppConfig {
    
    /// Retrieves the configuration value for the specified key from the Info.plist file.
    ///
    /// - Parameter key: The key for which to retrieve the configuration value.
    /// - Returns: The configuration value associated with the key, or an empty string if the key is not found.
    private func getConfigFor(key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let value = NSDictionary(contentsOfFile: path)?[key] as? String else {
                  return ""
              }
        return value
    }
    
    /// The base URL for the API, constructed using the value from build configuration.
    static let apiBaseUrl = "https://" + AppConfig().getConfigFor(key: "API_BASE_URL")
    
    /// The API key, retrieved from the value in build configuration.
    static let apiKey = AppConfig().getConfigFor(key: "API_KEY")
}

