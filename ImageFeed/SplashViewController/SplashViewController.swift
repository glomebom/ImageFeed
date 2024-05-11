//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Gleb on 12.04.2024.
//

import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imageView = UIImageView()
    
    weak var authViewController: AuthViewController?
    
    weak var profileViewController: ProfileViewController?
    
    private let oAuth2Service = OAuth2Service.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
        if oAuth2TokenStorage.token != nil {
            guard let token = oAuth2TokenStorage.token else { return }
            fetchProfile(token: token)
        } else {
            goToAuth()
        }
    }
}

extension SplashViewController {
    private func setupView() {
        view.backgroundColor = .ypBlack
        imageViewConfig()
    }
    
    private func imageViewConfig() {
        imageView.image = UIImage(named: "Vector")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 78),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

extension SplashViewController {
    private func goToAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let viewController: UINavigationController = storyboard.instantiateViewController(withIdentifier: "UINavigationController") as? UINavigationController,
              let authViewController = viewController.viewControllers[0] as? AuthViewController else {
            assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            return
        }
        authViewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(for: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let accessToken):
                self.oAuth2TokenStorage.token = accessToken
                self.didAuthenticate()
            case .failure(let error):
                authViewController?.showAlert(vc)
                print("[SplashViewController]: \(error)")
                break
            }
        }
    }
    
    func didAuthenticate() {
        self.dismiss(animated: true)
        guard let token = self.oAuth2TokenStorage.token else {
            return
        }
        fetchProfile(token: token)
    }
    
    func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profileData):
                let profile = profileService.prepareProfile(data: profileData)
                profileService.profileModel = profile
                guard let token = oAuth2TokenStorage.token else { return }
                fetchImageProfile(token: token, username: profileData.username)
            case .failure(let error):
                print("[SplashViewController]: \(error.localizedDescription)")
                break
            }
        }
    }
    
    func fetchImageProfile(token: String, username: String) {
        profileImageService.fetchProfileImageURL(token: token, username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageData):
                profileImageService.profileImageURL = imageData.profileImage.small
                switchToTabBarController()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SplashViewController {
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[SplashViewController]: Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}
