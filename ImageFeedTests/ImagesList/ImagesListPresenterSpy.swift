//
//  ImagesListPresenterSpy..swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var fetchPhotosNextPageWasCalled: Bool = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageWasCalled = true
    }
}
