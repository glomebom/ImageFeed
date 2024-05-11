//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Gleb on 11.05.2024.
//

import Foundation
struct PhotoResult: Codable {
    let id: String
    let created_at: String?
    let width, height: Double
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}
