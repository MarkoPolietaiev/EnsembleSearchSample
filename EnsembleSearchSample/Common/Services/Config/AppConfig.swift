//
//  AppConfig.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

class AppConfig {
    
    private func getConfigFor(key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let value = NSDictionary(contentsOfFile: path)?[key] as? String else {
                return ""
        }
        return value
    }
    
    static let apiBaseUrl = "https://" + AppConfig().getConfigFor(key: "API_BASE_URL")
    static let apiKey = AppConfig().getConfigFor(key: "API_KEY")
}
