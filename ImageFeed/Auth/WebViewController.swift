//
//  File.swift
//  ImageFeed
//
//  Created by Gleb on 03.04.2024.
//

import Foundation
import UIKit
import WebKit

public protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewController)
}

final class WebViewController: UIViewController & WebViewControllerProtocol {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var progressView: UIProgressView!
    
    private var estimatedProgressbservation: NSKeyValueObservation?
    
    weak var delegate: WebViewViewControllerDelegate?
    
    var presenter: WebViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        //updateProgress()
    }
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        estimatedProgressbservation = webView.observe(
        //            \.estimatedProgress,
        //             options: [],
        //             changeHandler: { [weak self] _, _ in
        //                 guard let self = self else { return }
        //                 //self.updateProgress()
        //             })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(webView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //    private func updateProgress() {
    //        progressView.progress = Float(webView.estimatedProgress)
    //        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    //    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
}

//extension WebViewController {
//    private func loadAuthView() {
//        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
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
//        webView.load(request)
//    }
//}

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if  let url = navigationAction.request.url {
            return presenter?.code(from: url)
        } else {
            return nil
        }
    }
}
