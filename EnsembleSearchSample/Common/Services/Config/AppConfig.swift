//
//  AppConfig.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

class AppConfig {
    
    private func getConfigFor(key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: path) as? [String: String],
            let value = config[key] else {
                fatalError("Config file not found")
        }
        return value
    }
    
    static let apiBaseUrl = "https://" + AppConfig().getConfigFor(key: "API_BASE_URL")
    static let apiKey = AppConfig().getConfigFor(key: "API_KEY")
}
