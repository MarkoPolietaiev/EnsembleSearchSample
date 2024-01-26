//
//  ApiService.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

protocol ApiServiceProtocol {
    func search(requestParameters: SearchRequest, completion: @escaping (Result<SearchResponse, Error>) -> Void)
}
