//
//  ApiService.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

protocol ApiServiceProtocol {
    func search(query: String, pageNumber: Int, year: Int?, type: MovieType?, completion: @escaping (Result<SearchResponse, Error>) -> Void)
}
