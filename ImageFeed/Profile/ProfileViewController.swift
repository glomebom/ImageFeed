//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Gleb on 15.03.2024.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton() {
    }
}
