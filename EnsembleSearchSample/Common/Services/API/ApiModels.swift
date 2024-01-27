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

struct SearchResponse: Decodable, Equatable {
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
    
    static func == (lhs: SearchResponse, rhs: SearchResponse) -> Bool {
        return lhs.search == rhs.search && lhs.totalResults == rhs.totalResults && lhs.response == rhs.response
    }
}

// MARK: - Search
struct Movie: Decodable, Equatable {
    var title, year, imdbID: String
    var type: MovieType = .unknown
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
        self.type = MovieType(rawValue: try container.decode(String.self, forKey: .type)) ?? .unknown
        self.poster = try container.decode(String.self, forKey: .poster)
    }
    
    init(title: String, year: String, imdbID: String, type: MovieType, poster: String) {
        self.title = title
        self.year = year
        self.imdbID = imdbID
        self.type = type
        self.poster = poster
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.title == rhs.title && lhs.year == rhs.year && lhs.imdbID == rhs.imdbID && lhs.type == rhs.type && lhs.poster == rhs.poster
    }
    
    static let `default` = Movie(title: "Star Wars", year: "2000", imdbID: "", type: .unknown, poster: "")
}

enum MovieType: String, Decodable, CaseIterable {
    case movie
    case series
    case episode
    case unknown
    case game
    
    var localizedValue: String {
        switch self {
        case .movie:
            R.string.localizable.movie()
        case .series:
            R.string.localizable.series()
        case .episode:
            R.string.localizable.episode()
        case .game:
            R.string.localizable.game()
        case .unknown:
            R.string.localizable.unknown()
        }
    }
}
