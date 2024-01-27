//
//  MockApiService.swift
//  EnsembleSearchSampleTests
//
//  Created by Marko Polietaiev on 2024-01-27.
//

import Foundation

class MockApiService: ApiServiceProtocol {
    
    func search(requestParameters: SearchRequest, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        let jsonString = """
                    {
                        "Search": [
                            {
                                "Title": "Star Wars: Episode IV - A New Hope",
                                "Year": "1977",
                                "imdbID": "tt0076759",
                                "Type": "movie",
                                "Poster": "https://m.media-amazon.com/images/M/MV5BOTA5NjhiOTAtZWM0ZC00MWNhLThiMzEtZDFkOTk2OTU1ZDJkXkEyXkFqcGdeQXVyMTA4NDI1NTQx._V1_SX300.jpg"
                            }
                        ],
                        "totalResults": "860",
                        "Response": "True"
                    }
                """
        if let data = jsonString.data(using: .utf8) {
            do {
                let response = try JsonManager.decode(SearchResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(APIError.errorResponse(message: "Error")))
            }
        } else {
            completion(.failure(APIError.errorResponse(message: "Error")))
        }
    }
}
