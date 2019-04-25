//
//  NetworkHttpClient.swift
//  Cake List
//
//  Created by Frank on 25/04/2019.

import Foundation

enum NetworkHttpClientError: Error {
    case NetworkError
}

class NetworkHttpClient: HttpClient {

    private var dataTask: URLSessionDataTask?

    func makeGETNetworkRequest(path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: path) else {
            return
        }
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadRevalidatingCacheData

        dataTask = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(Result.failure(error))
            } else if let data = data {
                completion(Result.success(data))
            } else {
                completion(Result.failure(NetworkHttpClientError.NetworkError))
            }
        }
        
        dataTask?.resume()
    }
}
