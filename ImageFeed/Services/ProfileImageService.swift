//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Gleb on 01.05.2024.
//

import Foundation

final class ProfileImageService {
    private enum GetUserImageDataError: Error {
            case invalidProfileImageRequest
        }
    
    static let shared = ProfileImageService()
    
    var profileImageURL: String?
    
    private var mainUrlProfile = "https://api.unsplash.com/users/"
    private var task: URLSessionTask?
    
    private init() {}
    
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        let imageUrlString = mainUrlProfile + username
        
        print("makeProfileImageRequest: \(imageUrlString)")
        
        guard let url = URL(string: imageUrlString) else {
            preconditionFailure("Error: unable to construct profileImageURL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<UserResult, Error>) -> Void) {
        task?.cancel()
        
        guard let requestWithTokenAndUsername = makeProfileImageRequest(token: token, username: username)  else {
            completion(.failure(GetUserImageDataError.invalidProfileImageRequest))
            return
        }
        
        let task = URLSession.shared.data(for: requestWithTokenAndUsername) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let profileImage = try JSONDecoder().decode(UserResult.self, from:data)
                        completion(.success(profileImage))
                    } catch {
                        completion(.failure(error))
                        print("Error: error of requesting: \(error)")
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("Error: error of requesting: \(error)")
                }
            }
        }
        self.task = task
        task.resume()
    }
}
