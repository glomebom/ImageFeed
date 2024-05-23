//
//  ProfileViewControllerMock.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed
import UIKit

final class ProfileViewControllerMock: ProfileViewControllerProtocol {
    let imageView = UIImageView()
    let exitButton = UIButton()
    let nameLabel = UILabel()
    let nickNameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    func updateView(data: ImageFeed.Profile) {
        nameLabel.text = data.name
        nickNameLabel.text = data.loginName
        descriptionLabel.text = data.bio
    }
    
    func setAvatar(url: URL) {
        
    }
}
