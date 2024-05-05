//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Gleb on 08.04.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decoderError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print("Error: \(statusCode)")
                    return
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("Error: \(error)")
                return
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("Error: urlSessionError")
                return
            }
        })
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Codable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let decoder = JSONDecoder()
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    do { let decodedData = try decoder.decode(T.self, from: data)
                        fulfillCompletionOnTheMainThread(.success(decodedData))
                    } catch {
                        print("\(String(describing: T.self)) [dataTask:] - Error of decoding: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.decoderError(error)))
                    }
                } else {
                    print("\(String(describing: T.self)) [dataTask:] - Network Error \(statusCode)" )
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    return
                }
            } else if let error = error {
                print("\(String(describing: T.self)) [URLRequest:] - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
        })
        return task
    }
}
