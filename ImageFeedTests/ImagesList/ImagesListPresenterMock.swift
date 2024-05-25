//
//  ImagesListPresenterMock.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed

final class ImagesListPresenterMock: ImagesListPresenterProtocol {
    private let imagesListService = ImagesListServiceSpy.shared
    var view: ImageFeed.ImagesListViewControllerProtocol?
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
}
