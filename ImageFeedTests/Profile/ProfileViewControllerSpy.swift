//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var updateViewWasCalled: Bool = false
    var setAvatarWasCalled: Bool = false
    
    func updateView(data: ImageFeed.Profile) {
        updateViewWasCalled = true
    }
    
    func setAvatar(url: URL) {
        setAvatarWasCalled = true
    }
}
