//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Gleb on 23.05.2024.
//

import Foundation
import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var updateTableViewAnimatedWasCalled: Bool = false
    
    func viewDidLoad() {
        presenter?.fetchPhotosNextPage()
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedWasCalled = true
    }
}
