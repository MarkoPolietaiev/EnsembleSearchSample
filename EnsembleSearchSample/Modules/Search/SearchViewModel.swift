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
    
    func search(query: String = "", isPagination: Bool = false, completion: @escaping (Result<SearchViewModelResponse, Error>) -> Void) {
        var request = searchRequest
        if isPagination {
            //if pagination, we need to check if there are more movies to load
            guard movies.count < totalResults else {
                completion(.failure(NSError(domain: "No more movies", code: 0, userInfo: nil)))
                return
            }
            // if there are more movies to load, we need to increment page number
            request.pageNumber += 1
        } else {
            // if we are not paginating, we need to reset page number and set new query
            request.setQuery(query)
            request.pageNumber = 1
        }
        
        apiService.search(requestParameters: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                // update search request parameters
                self.searchRequest = request
                if isPagination {
                    self.movies.append(contentsOf: response.search)
                } else {
                    self.movies = response.search
                    self.totalResults = Int(response.totalResults) ?? 0
                }
                completion(.success(SearchViewModelResponse(rowsAdded: response.search.count, isPagination: isPagination)))
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

struct SearchViewModelResponse {
    var rowsAdded: Int
    var isPagination: Bool
}
