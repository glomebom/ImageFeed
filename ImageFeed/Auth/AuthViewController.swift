//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Gleb on 02.04.2024.
//

import Foundation
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let buttonView = UIButton()
    
    override func viewDidLoad() {
        setupView()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc
    private func didTapLogonButton() {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: Any?.self)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func showAlert(_ vc: UIViewController)  {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "alertId"
        
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
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
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YPBlack")
    }
}
