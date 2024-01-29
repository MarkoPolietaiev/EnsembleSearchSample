//
//  ApiModels.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

struct SearchRequest {
    private(set) var query: String
    var pageNumber: Int
    var year: Int?
    var type: MovieType?
    
    mutating func setQuery(_ query: String) {
        self.query = query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct SearchResponse: Decodable {
    var search: [Movie]
    var totalResults, response: String

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
    
    init(search: [Movie], totalResults: String, response: String) {
        self.search = search
        self.totalResults = totalResults
        self.response = response
    }
}
