//
//  SearchViewModel.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

/// ViewModel class responsible for managing search-related data and interactions.
class SearchViewModel {
    
    private var movies: [Movie] = []
    private var totalResults: Int = 0
    private var searchRequest = SearchRequest(query: "", pageNumber: 1)
    
    /// Indicates whether there are more movies to load for pagination.
    var hasMore: Bool {
        return movies.count < totalResults
    }
    
    private var apiService: ApiServiceProtocol
    
    /// Initializes the ViewModel with the specified ApiService.
    init(apiService: ApiServiceProtocol) {
        self.apiService = apiService
    }
    
    /// Initiates a search request with optional query and pagination parameters.
    ///
    /// - Parameters:
    ///   - query: The search query string.
    ///   - isPagination: A flag indicating whether pagination is requested.
    ///   - completion: A closure to be executed once the search request is completed.
    func search(query: String = "", isPagination: Bool = false, completion: @escaping (Result<SearchResultUpdate, Error>) -> Void) {
        var request = searchRequest
        if isPagination {
            // if pagination need to check if there are more movies to load
            guard movies.count < totalResults else {
                completion(.failure(NSError(domain: "No more movies", code: 0, userInfo: nil)))
                return
            }
            // if there are more movies to load need to increment page number
            request.pageNumber += 1
        } else {
            request.setQuery(query)
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
                completion(.success(SearchResultUpdate(rowsAdded: response.search.count, isPagination: isPagination)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Retrieves the movie at the specified index.
    ///
    /// - Parameter index: The index of the movie.
    /// - Returns: The movie at the specified index or nil if the index is out of bounds.
    func movie(at index: Int) -> Movie? {
        guard index < movies.count else { return nil }
        return movies[index]
    }
    
    /// Retrieves the total count of movies in the ViewModel.
    ///
    /// - Returns: The total count of movies.
    func moviesCount() -> Int {
        return movies.count
    }
    
    /// Clears the movies, resets the page number, and sets total results to zero.
    func clear() {
        movies.removeAll()
        searchRequest.pageNumber = 1
        totalResults = 0
    }
    
    /// Retrieves the currently set year filter.
    ///
    /// - Returns: The currently set year filter or nil if not set.
    func getYear() -> Int? {
        return searchRequest.year
    }
    
    /// Retrieves the currently set movie type filter.
    ///
    /// - Returns: The currently set movie type filter or nil if not set.
    func getType() -> MovieType? {
        return searchRequest.type
    }
    
    /// Sets the year filter for the search request.
    ///
    /// - Parameter year: The year to set as the filter.
    func setYear(_ year: Int?) {
        searchRequest.year = year
    }
    
    /// Sets the movie type filter for the search request.
    ///
    /// - Parameter type: The movie type to set as the filter.
    func setType(_ type: MovieType?) {
        searchRequest.type = type
    }
}

/// Represents the response structure for the SearchViewModel search method.
struct SearchResultUpdate {
    var rowsAdded: Int // Used to insert table rows on pagination
    var isPagination: Bool
}
