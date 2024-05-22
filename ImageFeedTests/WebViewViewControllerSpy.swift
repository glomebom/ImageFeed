//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Gleb on 21.05.2024.
//

import Foundation
import ImageFeed

final class WebViewViewControllerSpy: WebViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
