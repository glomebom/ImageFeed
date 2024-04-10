//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Gleb on 02.04.2024.
//

import Foundation
import UIKit

final class AuthViewController: UIViewController {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let buttonView = UIButton()
    
    private let oauth2Service = OAuth2Service.shared
    
    var oAuth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        setupView()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc
    private func didTapLogonButton() {
        performSegue(withIdentifier: ShowWebViewSegueIdentifier, sender: Any?.self)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
        OAuth2Service().fetchOAuthToken(for: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let oAuthTokenResponseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    oAuth2TokenStorage.token = oAuthTokenResponseBody.access_token
                    print("\(oAuth2TokenStorage.token)")
                } catch {
                    //handler(.failure(error))
                }
            case .failure:
                print("Ошибка")
            }
            //
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController {
    private func setupView() {
        view.backgroundColor = .ypBlack
        setupLogo()
        setupLogonButton()
    }
    
    private func setupLogo() {
        let logoImage = UIImage(named: "splash_logo")
        let imageView = UIImageView(image: logoImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupLogonButton() {
        buttonView.addTarget(self, action: #selector(self.didTapLogonButton), for: .touchUpInside)
        buttonView.setTitle("Войти", for: .normal)
        buttonView.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        buttonView.setTitleColor(.ypBlack, for: .normal)
        buttonView.backgroundColor = .ypWhite
        buttonView.layer.cornerRadius = 16
        buttonView.layer.masksToBounds = true
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonView)
        
        NSLayoutConstraint.activate([
            buttonView.heightAnchor.constraint(equalToConstant: 48),
            buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YPBlack") // 4
    }
}
