//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Gleb on 15.03.2024.
//

import Foundation
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let imageView = UIImageView()
    private let exitButton = UIButton()
    private let nameLabel = UILabel()
    private let nickNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Подписывание на блоках
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
        guard let profileModel = profileService.profileModel else {
            print("Try to read: profileService.profileModel")
            return }
        setupView()
        updateView(data: profileModel)
    }
    
    //    @IBAction func didTapLogoutButton() {
    //        // TODO: реализовать выход из профиля
    //        print("DEBUG: try to logout")
    //    }
    
    @objc
    private func didTapLogoutButton(sender: UIButton) {
        print("DEBUG: try to logout")
    }
}

extension ProfileViewController {
    func updateView(data: Profile) {
        //imageView
        nameLabel.text = data.name
        nickNameLabel.text = data.loginName
        descriptionLabel.text = data.bio
    }
    
    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.profileImageURL,
              let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновитt аватар, используя Kingfisher
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
        // Создание фото профиля
        imageView.image = UIImage(named: "Photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Констрейнты для фото профиля
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func exitButtonConfig() {
        // Создание кнопки выхода
        let exitImage = UIImage(named: "exit")
        exitButton.setImage(exitImage, for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        // Констрейнты для кнопки выхода
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func nameLabelConfig() {
        // Создание лейбла с именем
        //nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold/*UIFont.Weight(rawValue: 700.00)*/)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        // Констрейнты для лейбла с именем
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    private func nickNameLabelConfig() {
        //Создание лейбла с ником
        //nickNameLabel.text = "@ekaterina_nov"
        nickNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        nickNameLabel.textColor = .ypGray
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickNameLabel)
        
        // Констрейнты для лейбла с ником
        NSLayoutConstraint.activate([
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func descriptionLabelConfig() {
        // Создание лейбла с описанием
        //descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // Констрейнты для лейбла с описанием
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8)
        ])
    }
}
