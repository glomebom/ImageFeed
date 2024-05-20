//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Gleb on 11.05.2024.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width, height: Double
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}
