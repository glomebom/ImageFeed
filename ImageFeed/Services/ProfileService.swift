//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Gleb on 19.04.2024.
//

import Foundation

final class ProfileService {
    
    private enum GetUserDataError: Error {
        case invalidProfileRequest
    }
    
    static let shared = ProfileService()
    
    var profileModel: Profile?
    private var mainUrlProfile = "https://api.unsplash.com/me"
    private var task: URLSessionTask?
    
    private init() {}
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: mainUrlProfile) else {
            preconditionFailure("Error: unable to construct baseUrl")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let requestWithToken = makeProfileRequest(token: token) else {
            completion(.failure(GetUserDataError.invalidProfileRequest))
            return
        }
        
        let task = URLSession.shared.data(for: requestWithToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let profileData = try JSONDecoder().decode(ProfileResult.self, from:data)
                        completion(.success(profileData))
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
    
    func prepareProfile(data: ProfileResult) -> Profile {
        let username = data.username
        let name = data.firstName + " " + data.lastName
        let loginName = "@" + data.username
        let bio = data.bio
        let profile = Profile(username: username,
                              name: name,
                              loginName: loginName,
                              bio: bio)
        return profile
    }
}
