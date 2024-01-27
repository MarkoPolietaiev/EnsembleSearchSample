//
//  EnsembleSearchSampleTests.swift
//  EnsembleSearchSampleTests
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import XCTest
@testable import EnsembleSearchSample

final class EnsembleSearchSampleApiTests: XCTestCase {
    
    var mockApiService: MockApiService?
    
    override func setUp() {
        mockApiService = MockApiService()
        super.setUp()
    }
    
    override func tearDown() {
        mockApiService = nil
        super.tearDown()
    }

    func testFetchData() {
        let expectation = self.expectation(description: "Fetch movie data")
        mockApiService?.search(requestParameters: SearchRequest(query: "Star Wars", pageNumber: 1)) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.search.first?.title, "Star Wars: Episode IV - A New Hope")
                XCTAssertEqual(response.search.first?.type, MovieType.movie)
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
