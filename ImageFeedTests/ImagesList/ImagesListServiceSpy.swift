//
//  ImagesListServiceSpy.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    static let shared = ImagesListServiceSpy()
    private (set) var photos: [Photo] = []
    var photosWereUpdated: Bool = false
        
    func fetchPhotosNextPage() {
        photosWereUpdated = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {}
}
