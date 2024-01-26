//
//  ApiService.swift
//  EnsembleSearchSample
//
//  Created by Marko Polietaiev on 2024-01-24.
//

import Foundation
import Network

class ApiService {
    
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
        case year = "y"
        case type
        case page
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
    
    private var activeTasks: [URLSessionDataTask] = []
    
    private func request(type: RequestType, endpoint: EndpointType? = nil, parameters: [ParameterType: Any] = [:], contentType: ContentType = .json, completion: @escaping (Data?, Error?) -> Void) {
        let urlString = baseUrl + (endpoint?.rawValue ?? "")
        guard var urlComponents = URLComponents(string: urlString) else {
            completion(nil, nil)
            return
        }

        // Convert parameters to URL query items
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key.rawValue, value: "\(value)")
            queryItems.append(queryItem)
        }
        
        // Add API key
        queryItems.append(URLQueryItem(name: ParameterType.apiKey.rawValue, value: AppConfig.apiKey))

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

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
        var task: URLSessionDataTask?  // Declare task as an implicitly unwrapped optional

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            print("API Request ---> " + (request.url?.path ?? "") + (request.url?.query ?? ""))

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                if let error = error {
                    if !hasInternetConnection() {
                        // No internet connection
                        completion(nil, APIError.noConnection)
                    } else if error._code == NSURLErrorTimedOut {
                        // Request timed out
                        completion(nil, APIError.timeout)
                    } else if error._code == NSURLErrorCancelled {
                        // Request canceled
                        completion(nil, nil)
                    } else {
                        if currentRetry < maxRetries {
                            // Implement a backoff strategy
                            let delay = pow(2.0, Double(currentRetry))
                            print("API Request ---> " + (request.url?.path ?? "") + " | Retry \(currentRetry + 1) of \(maxRetries) in \(delay) seconds")
                            
                            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                                // Check if the task has been canceled before retrying
                                if task?.state != .completed && task?.state != .canceling {
                                    _ = self.performRequest(request: request, maxRetries: maxRetries, currentRetry: currentRetry + 1, completion: completion)
                                }
                            }
                        } else {
                            // Max retries reached, return the error
                            completion(nil, error)
                        }
                    }
                } else {
                    // Request successful, return data
                    completion(data, nil)
                }

                // Remove the task from the active tasks array
                if let task, let index = self.activeTasks.firstIndex(of: task) {
                    self.activeTasks.remove(at: index)
                }
            }
        }

        if let task = task {
            cancelRequest(task)
            task.resume()
            activeTasks.append(task)
            return task
        } else {
            fatalError("URLSessionDataTask is nil.")
        }
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
    private func cancelRequest(_ task: URLSessionDataTask) {
        if let index = activeTasks.firstIndex(of: task) {
            print("Cancelling request ---> \(task.originalRequest?.url?.path() ?? "")")
            task.cancel()
            activeTasks[index].cancel()
            activeTasks.remove(at: index)
        }
    }

    // Cancel all active requests
    func cancelAllRequests() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    private func hasInternetConnection() -> Bool {
        let monitor = NWPathMonitor()

        let semaphore = DispatchSemaphore(value: 0)

        var isConnected = false

        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)

        // Wait for the asynchronous pathUpdateHandler to be called
        _ = semaphore.wait(timeout: .now() + 1)

        return isConnected
    }
}

extension ApiService: ApiServiceProtocol {
    func search(requestParameters: SearchRequest, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        var parameters: [ParameterType: Any] = [
            .searchQuery: requestParameters.query,
            .page: requestParameters.pageNumber
        ]
        if let year = requestParameters.year {
            parameters[.year] = year
        }
        if let type = requestParameters.type {
            parameters[.type] = type.rawValue
        }
        request(type: .get, parameters: parameters) { data, error in
            if let error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let response = try JsonManager.decode(SearchResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    do {
                        let errorResponse = try JsonManager.decode(ErrorResponse.self, from: data)
                        completion(.failure(APIError.errorResponse(message: errorResponse.error)))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
