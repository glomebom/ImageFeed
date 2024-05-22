//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Gleb on 20.05.2024.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code (from url: URL) -> String?
    
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewControllerProtocol?
    
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
//        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
//            print("Ошибка unsplashAuthorizeURLString")
//            return
//        }
//        
//        urlComponents.queryItems = [
//            URLQueryItem(name: "client_id", value: Constants.accessKey),
//            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "scope", value: Constants.accessScope)
//        ]
//        
//        guard let url = urlComponents.url else {
//            print("Ошибка формирования url")
//            return
//        }
//        
//        let request = URLRequest(url: url)
        
        guard let request = authHelper.authRequest()else { return }
        
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
//        if  let urlComponents = URLComponents(string: url.absoluteString),
//            urlComponents.path == "/oauth/authorize/native",
//            let items = urlComponents.queryItems,
//            let codeItem = items.first(where: { $0.name == "code" })
//        {
//            return codeItem.value
//        } else {
//            return nil
//        }
    }
}
