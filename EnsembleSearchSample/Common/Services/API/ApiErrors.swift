//
//  ApiErrors.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case unauthorized
}

enum NetworkError: Error {
    case noConnection
    case timeout
}
