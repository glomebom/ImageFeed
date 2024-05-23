//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Gleb on 15.03.2024.
//

import Foundation
import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateView(data: Profile)
    func setAvatar(url: URL)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    private let imageView = UIImageView()
    private let exitButton = UIButton()
    private let nameLabel = UILabel()
    private let nickNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let profileImageService = ProfileImageService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ProfilePresenter(view: self)
        
        setupView()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.updateAvatar()
            }
        presenter?.updateAvatar()
        presenter?.updateProfileDetails()
    }
    
    @objc
    private func didTapButton() {
        showAlert()
    }
}

extension ProfileViewController {
    func showAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(
            title: "Да",
            style: .default) { _ in
                alert.dismiss(animated: true)
                self.presenter?.logout()
                
                guard let window = UIApplication.shared.windows.first else {
                    assertionFailure("confirmExit Invalid Configuration")
                    return
                }
                window.rootViewController = SplashViewController()
            }
        
        let noAction = UIAlertAction(
            title: "Нет",
            style: .default) { _ in
                alert.dismiss(animated: true)
            }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
}

extension ProfileViewController {
    func updateView(data: Profile) {
        nameLabel.text = data.name
        nickNameLabel.text = data.loginName
        descriptionLabel.text = data.bio
    }
    
    func setAvatar(url: URL) {
        imageView.kf.setImage(with: url)
    }
}

extension ProfileViewController {
    private func  setupView() {
        view.backgroundColor = .ypBlack
        profileImageConfig()
        exitButtonConfig()
        nameLabelConfig()
        nickNameLabelConfig()
        descriptionLabelConfig()
    }
    
    private func profileImageConfig() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func exitButtonConfig() {
        let exitImage = UIImage(named: "exit")
        guard let exitImage else { return }
        let exitButton = UIButton.systemButton(
            with: exitImage,
            target: self,
            action: #selector(Self.didTapButton)
        )
        exitButton.tintColor = UIColor(named: "YPRed")
        exitButton.setImage(exitImage, for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.accessibilityIdentifier = "Logout button"
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func nameLabelConfig() {
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func nickNameLabelConfig() {
        nickNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        nickNameLabel.textColor = .ypGray
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickNameLabel)
        
        NSLayoutConstraint.activate([
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func descriptionLabelConfig() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8)
        ])
    }
}
