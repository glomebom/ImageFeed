//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {
    func testViewDidLoadCallsFetchPhotosNextPage() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        viewController.viewDidLoad()
        
        XCTAssertTrue(presenter.fetchPhotosNextPageWasCalled)
    }
    
    func testNewPhotosUploadedAfterFetchPhotoWasCalled() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterMock()
        let imageService = ImagesListServiceSpy.shared
        viewController.presenter = presenter
        presenter.view = viewController
        
        viewController.presenter?.fetchPhotosNextPage()
        
        XCTAssertTrue(imageService.photosWereUpdated)
    }
}
