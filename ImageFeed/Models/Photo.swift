//
//  Photo.swift
//  ImageFeed
//
//  Created by Gleb on 11.05.2024.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
