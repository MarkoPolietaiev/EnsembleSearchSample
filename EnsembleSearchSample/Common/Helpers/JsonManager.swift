//
//  JsonManager.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

/// Singleton class used to decode JSON with detailed error explanation.
class JsonManager {

    typealias Output = Data
    typealias Input = Data

    func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        do {
            return try JsonManager.decode(type, from: from)
        } catch {
            throw error
        }
    }

    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        do {
            return try JsonManager.encode(value)
        } catch {
            throw error
        }
    }

    /// Decode a JSON.
    /// ``` swift
    /// JsonManager.decode(Object.self, data: Data())
    /// ```
    /// - Parameters:
    ///
    static func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch let error as DecodingError {
            let typeName = String(describing: type)
            switch error {
            case .dataCorrupted(let context):
                print("=== JSON DECODING ERROR - \(typeName) decoding error: data corrupted - \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("=== JSON DECODING ERROR - \(typeName) decoding error: key '\(key.stringValue)' not found - \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("=== JSON DECODING ERROR - \(typeName) decoding error: type mismatch for type '\(type)' - \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("=== JSON DECODING ERROR - \(typeName) decoding error: value of type '\(type)' not found - \(context.debugDescription)")
            @unknown default:
                print("=== JSON DECODING ERROR - \(typeName) decoding error: unknown decoding error - \(error.localizedDescription)")
            }
            print("=== JSON DECODING ERROR Details: \(error)")
            throw error
        } catch {
            throw error
        }
    }

    /// Encode a JSON.
    /// ``` swift
    /// JsonManager.encode(Object.self, dateEncodingStrategy: .formatted(.iso8601Full))
    /// ```
    /// - Parameters:
    ///    - outputFormatting: set to [.sortedKeys] by default.
    static func encode<T>(_ value: T, outputFormatting: JSONEncoder.OutputFormatting = [.sortedKeys]) throws -> Data where T : Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormatting
        do {
            return try encoder.encode(value)
        } catch let error as EncodingError {
            let typeName = String(describing: T.self)
            switch error {
            case .invalidValue(let value, let context):
                print("=== JSON ENCODING ERROR - \(typeName) encoding error: invalid value '\(value)' - \(context.debugDescription)")
            @unknown default:
                print("=== JSON ENCODING ERROR - \(typeName) encoding error: unknown encoding error - \(error.localizedDescription)")
            }
            print("=== JSON ENCODING ERROR Details: \(error)")
            throw error
        } catch {
            throw error
        }
    }
}
