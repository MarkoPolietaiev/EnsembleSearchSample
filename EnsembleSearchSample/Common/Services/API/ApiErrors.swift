//
//  ApiErrors.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-25.
//

import Foundation

enum APIError: Error {
    case errorResponse(message: String)
    case noConnection
    case timeout
}

struct ErrorResponse: Decodable {
    var error: String
    var response: String
    
    enum CodingKeys: String, CodingKey {
        case error = "Error"
        case response = "Response"
    }
}
