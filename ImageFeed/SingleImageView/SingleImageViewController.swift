//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Gleb on 17.03.2024.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    // Приватный аутлет для исключения обращения напрямую
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        // Размеры view под размеры изображения
        imageView.frame.size = image.size
        
        // Параметры zoom
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    // Скрытие view по нажатию на кнопку
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

// Реализация метода выбора view к которой будет применяться zoom
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // Передаем view с размерами полученными в viewDidLoad
        imageView
    }
}
