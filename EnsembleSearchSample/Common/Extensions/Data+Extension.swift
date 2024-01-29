//
//  Data+Extension.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

extension Data {
    
    /// A computed property that returns a pretty-printed JSON string representation of the raw JSON data.
    ///
    /// - Returns: A String containing the pretty-printed JSON representation, or nil if conversion encounters errors.
    var prettyPrintedJSONString: String? {
        // Attempt to deserialize the raw JSON data into a native Swift object
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              // Serialize the object back to Data with the .prettyPrinted option
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              // Convert the resulting Data to a UTF-8 encoded string
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }
        
        return prettyPrintedString
    }
}
