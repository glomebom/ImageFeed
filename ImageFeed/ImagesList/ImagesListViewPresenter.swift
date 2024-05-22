//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Gleb on 22.05.2024.
//

import Foundation

public protocol ImagesListPresenterProtocol {
    var view: ImagesListPresenterProtocol? { get set }
    func fetchPhotosNextPage()
}
