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
        return request as URLRequest
    }
    
    func fetchOAuthToken(for code: String, handler: @escaping (Result<Data,Error>) -> Void) {
        
        let requestWithCode = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.dataTask(with: requestWithCode){ data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.urlSessionError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}

//200 — запрашиваемое действие выполнено;
//401 — для выполнения действия надо выполнить авторизацию (получить разрешение);
//404 — ресурс не найден либо временно недоступен (стоит повторить запрос через какое-то время);
//500 — при попытке выполнения запроса произошла ошибка сервера.

