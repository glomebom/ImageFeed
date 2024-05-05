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
    
    weak var authViewController: AuthViewController?
    
    weak var profileViewController: ProfileViewController?
    
    private let oAuth2Service = OAuth2Service.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oAuth2TokenStorage.token != nil {
            guard let token = oAuth2TokenStorage.token else { return }
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
                //Алерт
                authViewController?.showAlert(vc)
                print("[SplashViewController]: \(error)")
                break
            }
        }
    }
    
    func didAuthenticate(/*_ vc: AuthViewController*/) {
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
                fetchImageProfile(token: token, username: profile.username)
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
                ///
                print("DEBUG: fetchProfileImageURL: \(imageData.profileImage.small)")
                ///
                switchToTabBarController()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SplashViewController {
    private func switchToTabBarController() {
        // Получение экземпляра window
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[SplashViewController]: Invalid window configuration")
            return
        }
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}
