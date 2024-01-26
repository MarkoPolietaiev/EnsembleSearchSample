//
//  SearchViewModel.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

class SearchViewModel {
    
    private var movies: [Movie] = []
    private var totalResults: Int = 0
    private var searchRequest = SearchRequest(query: "", pageNumber: 1)
    
    var hasMore: Bool {
        return movies.count < totalResults
    }
    
    private var apiService: ApiServiceProtocol
    
    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }
    
    func search(query: String = "", isPagination: Bool = false, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        var request = searchRequest
        if isPagination {
            guard movies.count < totalResults else {
                completion(.failure(NSError(domain: "No more movies", code: 0, userInfo: nil)))
                return
            }
            request.pageNumber += 1
        } else {
            request.query = query
            request.pageNumber = 1
        }
        
        apiService.search(requestParameters: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.searchRequest = request
                if isPagination {
                    self.movies.append(contentsOf: response.search)
                } else {
                    self.movies = response.search
                    self.totalResults = Int(response.totalResults) ?? 0
                }
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
        searchRequest.pageNumber = 1
        totalResults = 0
    }
    
    func getYear() -> Int? {
        return searchRequest.year
    }
    
    func getType() -> MovieType? {
        return searchRequest.type
    }
    
    func setYear(_ year: Int?) {
        searchRequest.year = year
    }
    
    func setType(_ type: MovieType?) {
        searchRequest.type = type
    }
}
