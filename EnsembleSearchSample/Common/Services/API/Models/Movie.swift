//
//  Movie.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-28.
//

import Foundation

struct Movie: Decodable {
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
