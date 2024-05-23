//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testProfileUpdateLabels() {
        let view = ProfileViewControllerMock()
        let profile = Profile(username: "gleb", name: "Gleb Glebov", loginName: "@gleb", bio: "progger")
        
        view.updateView(data: profile)
        
        XCTAssertEqual(view.nameLabel.text, profile.name)
    }
    
    func testViewDidLoadCallsUpdateProfileDetails() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        presenter.updateProfileDetails()
        
        XCTAssertTrue(presenter.updateProfileDetailsWasCalled)
    }
    
    func testViewDidLoadCallsUpdateAvatar() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        presenter.updateAvatar()
        
        XCTAssertTrue(presenter.updateAvatarWasCalled)
    }
    
    func testCallsLogout() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        presenter.logout()
        
        XCTAssertTrue(presenter.logoutWasCalled)
    }
    
    func testProfileViewControllerUpdateView() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let profile = Profile(username: "gleb", name: "Gleb Glebov", loginName: "@gleb", bio: "progger")
        presenter.view?.updateView(data: profile)
        
        XCTAssertTrue(viewController.updateViewWasCalled)
    }
    
    func testProfileViewControllerSetAvatar() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let url = Constants.defaultBaseURL
        presenter.view?.setAvatar(url: url)
        
        XCTAssertTrue(viewController.setAvatarWasCalled)
    }
}
