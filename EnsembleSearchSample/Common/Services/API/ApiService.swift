//
//  ApiService.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation

class ApiService {
    
    static let shared = ApiService()
    
    private let baseUrl: String = AppConfig.apiBaseUrl
    
    private enum RequestType: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
    }
    
    enum EndpointType {
        case signIn
        
        var rawValue: String {
            switch self {
            case .signIn:
                return "/api/v1/auth/email/login"
            }
        }
    }
    
    private enum ParameterType: String {
        case apiKey
        case searchQuery = "s"
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
    
    private var activeTasks: [URLSessionDataTask] = []
    
    private func request(type: RequestType, endpoint: EndpointType? = nil, parameters: [ParameterType: Any] = [:], encodedBody: Data? = nil, contentType: ContentType = .json, completion: @escaping (Data?, Error?) -> Void) {
        let urlString = baseUrl + (endpoint?.rawValue ?? "")
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

        // Add Authorization header with bearer token if useToken is true
        var parameters = parameters
        parameters[.apiKey] = AppConfig.apiKey

        if !parameters.isEmpty {
            let jsonData = try? JSONSerialization.data(withJSONObject: convertParametersDictionary(originalDict: parameters))
            request.httpBody = jsonData
        } else if let encodedBody {
            request.httpBody = encodedBody
        }

        // Set timeout interval for the request (60 seconds)
        request.timeoutInterval = 60

        // Number of retries
        let maxRetries = 3

        // Perform the request with retries
        let task = performRequest(request: request, maxRetries: maxRetries, currentRetry: 0) { data, error in
            completion(data, error)
        }
        activeTasks.append(task)
    }

    private func performRequest(request: URLRequest, maxRetries: Int, currentRetry: Int, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        var task: URLSessionDataTask!  // Declare task as an implicitly unwrapped optional

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            print("API Request ---> " + (request.url?.path() ?? "") + (request.httpBody?.prettyPrintedJSONString ?? ""))
            DispatchQueue.main.async {
                if let error = error {
                    if currentRetry < maxRetries {
                        // Implement a backoff strategy
                        let delay = pow(2.0, Double(currentRetry))
                        print("API Request ---> " + (request.url?.path() ?? "") + " | Retry \(currentRetry + 1) of \(maxRetries) in \(delay) seconds")
                        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                            // Check if the task has been canceled before retrying
                            if task.state != .completed && task.state != .canceling {
                                let _ = self.performRequest(request: request, maxRetries: maxRetries, currentRetry: currentRetry + 1, completion: completion)
                            }
                        }
                    } else {
                        // Max retries reached, return the error
                        completion(nil, error)
                    }
                } else {
                    // Request successful, return data
                    completion(data, nil)
                }

                // Remove the task from the active tasks array
                if let index = self.activeTasks.firstIndex(of: task) {
                    self.activeTasks.remove(at: index)
                }
            }
        }
        cancelRequest(task)
        task.resume()
        activeTasks.append(task)
        return task
    }
    
    private func convertParametersDictionary(originalDict: [ParameterType: Any]) -> [String: Any] {
        var newDictionary: [String: Any] = [:]

        for (key, value) in originalDict {
            // Convert the enum key to its raw value (String)
            let stringKey = key.rawValue
            // Add the entry to the new dictionary
            newDictionary[stringKey] = value
        }

        return newDictionary
    }

    // Cancel a specific request
    func cancelRequest(_ task: URLSessionDataTask) {
        if let index = activeTasks.firstIndex(of: task) {
            print("Cancelling request ---> \(task.originalRequest?.url?.path() ?? "")")
            activeTasks[index].cancel()
            activeTasks.remove(at: index)
        }
    }

    // Cancel all active requests
    func cancelAllRequests() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
}

extension ApiService: ApiServiceProtocol {
    func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        request(type: .get, parameters: [.searchQuery: query]) { data, error in
            if let error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let response = try JsonManager.decode(SearchResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
