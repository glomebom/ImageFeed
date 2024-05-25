//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var updateProfileDetailsWasCalled: Bool = false
    var updateAvatarWasCalled: Bool = false
    var logoutWasCalled: Bool = false
    
    func updateProfileDetails() {
        updateProfileDetailsWasCalled = true
    }
    
    func updateAvatar() {
        updateAvatarWasCalled = true
    }
    
    func logout() {
        logoutWasCalled = true
    }
}
