//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Gleb on 06.04.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            preconditionFailure("Unable to construct baseUrl")
        }
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
            + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
        ) else {
            preconditionFailure("Unable to construct url")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(for code: String, completion: @escaping (Result<String,Error>) -> Void) {
        let requestWithCode = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: requestWithCode){ result in
            switch result {
            case .success(let data):
                do {
                    let oAuthToken = try JSONDecoder().decode(OAuthTokenResponseBody.self, from:data)
                    guard let accessToken = oAuthToken.access_token else {
                        fatalError("Can`t decode token!")
                    }
                    completion(.success(accessToken))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

//200 — запрашиваемое действие выполнено;
//401 — для выполнения действия надо выполнить авторизацию (получить разрешение);
//404 — ресурс не найден либо временно недоступен (стоит повторить запрос через какое-то время);
//500 — при попытке выполнения запроса произошла ошибка сервера.

