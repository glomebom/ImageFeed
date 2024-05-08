//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Gleb on 21.04.2024.
//

import Foundation

struct ProfileResult: Codable {
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
    
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
}
