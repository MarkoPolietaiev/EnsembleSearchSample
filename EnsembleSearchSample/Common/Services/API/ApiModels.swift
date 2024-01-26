//
//  ApiModels.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

struct SearchResponse: Decodable {
    var search: [Movie]
    var totalResults, response: String

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
}

// MARK: - Search
struct Movie: Decodable {
    var title, year, imdbID: String
    var type: MovieTypeEnum = .unknown
    var poster: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.year = try container.decode(String.self, forKey: .year)
        self.imdbID = try container.decode(String.self, forKey: .imdbID)
        self.type = MovieTypeEnum(rawValue: try container.decode(String.self, forKey: .type)) ?? .unknown
        self.poster = try container.decode(String.self, forKey: .poster)
    }
}

enum MovieTypeEnum: String, Decodable {
    case movie
    case series
    case episode
    case unknown
}
