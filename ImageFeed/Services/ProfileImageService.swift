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
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    var profileImageURL: String?
    
    private var mainUrlProfile = "https://api.unsplash.com/users/"
    private var task: URLSessionTask?
    
    private init() {}
    
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        let imageUrlString = mainUrlProfile + username
        guard let url = URL(string: imageUrlString) else {
            preconditionFailure("Error: unable to construct profileImageURL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<UserResult, Error>) -> Void) {
        
        guard task == nil else { return }
        
        guard let requestWithTokenAndUsername = makeProfileImageRequest(token: token, username: username)  else {
            completion(.failure(GetUserImageDataError.invalidProfileImageRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: requestWithTokenAndUsername) { (result: Result<UserResult,Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let decodedData):
                    completion(.success(decodedData))
                    NotificationCenter.default
                        .post(name: ProfileImageService.didChangeNotification,
                              object: self,
                              userInfo: ["URL": decodedData])
                case .failure(let error):
                    completion(.failure(error))
                    print("[ProfileImageService]: \(error)")
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
