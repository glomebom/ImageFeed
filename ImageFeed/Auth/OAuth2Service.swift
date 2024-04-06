//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Gleb on 06.04.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    //private init()
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL = URL(string: "https://unsplash.com")!
        if let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
            + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type="authorization_code",
            relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
        ) {
            if var request = URLRequest(url: url) {
                request.httpMethod = "POST"
                return request
            }
        }
    }
}

