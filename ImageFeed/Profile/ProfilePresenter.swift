//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Gleb on 22.05.2024.
//

import Foundation
import Kingfisher

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func updateProfileDetails()
    func updateAvatar()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    init(view: ProfileViewControllerProtocol? = nil) {
        self.view = view
    }
    
    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.profileImageURL,
              let url = URL(string: profileImageURL)
        else { return }
        view?.setAvatar(url: url)
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profileModel else {
            print("Try to read: profileService.profileModel")
            return
        }
        view?.updateView(data: profile)
    }
    
    func logout() {
        profileLogoutService.logout()
    }
    
}
