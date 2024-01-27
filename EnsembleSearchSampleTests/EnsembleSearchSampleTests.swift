//
//  EnsembleSearchSampleTests.swift
//  EnsembleSearchSampleTests
//
//  Created by Marko Polietaiev on 2024-01-27.
//

import XCTest

final class EnsembleSearchSampleTests: XCTestCase {

    func testPrettyPrintedJson() throws {
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
        let expectedString = "{\n  \"totalResults\" : \"860\",\n  \"Response\" : \"True\",\n  \"Search\" : [\n    {\n      \"Year\" : \"1977\",\n      \"Type\" : \"movie\",\n      \"Title\" : \"Star Wars: Episode IV - A New Hope\",\n      \"imdbID\" : \"tt0076759\",\n      \"Poster\" : \"https:\\/\\/m.media-amazon.com\\/images\\/M\\/MV5BOTA5NjhiOTAtZWM0ZC00MWNhLThiMzEtZDFkOTk2OTU1ZDJkXkEyXkFqcGdeQXVyMTA4NDI1NTQx._V1_SX300.jpg\"\n    }\n  ]\n}"
        if let data = jsonString.data(using: .utf8) {
            XCTAssertEqual(data.prettyPrintedJSONString ?? "", expectedString)
        } else {
            XCTFail("Data error")
        }
    }
}
