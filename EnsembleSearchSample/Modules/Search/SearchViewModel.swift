//
//  SearchViewModel.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

class SearchViewModel {
    
    private var movies: [Movie] = []
    private var pageNumber: Int = 1
    private var totalResults: Int = 0
    private var query: String = ""
    var hasMore: Bool {
        return movies.count < totalResults
    }
    
    private var apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }
    
    func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        self.query = query
        apiService.search(query: query, pageNumber: pageNumber, year: nil, type: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.movies = response.search
                self.totalResults = Int(response.totalResults) ?? 0
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadMore(completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard movies.count < totalResults else {
            completion(.failure(NSError(domain: "No more movies", code: 0, userInfo: nil)))
            return
        }
        apiService.search(query: query, pageNumber: pageNumber+1, year: nil, type: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.pageNumber += 1
                self.movies.append(contentsOf: response.search)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func movie(at index: Int) -> Movie? {
        guard index < movies.count else { return nil }
        return movies[index]
    }
    
    func moviesCount() -> Int {
        return movies.count
    }
    
    func clear() {
        movies.removeAll()
        pageNumber = 1
        totalResults = 0
    }
}
