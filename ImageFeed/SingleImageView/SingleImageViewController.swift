//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Gleb on 17.03.2024.
//

import Foundation
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    private var imageURL: String?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 10
        
        setImage()
    }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController {
    func setImageURL(imageURL: String) {
        self.imageURL = imageURL
    }
    
    func setImage() {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            print("[SingleImageViewController]: error of creating URL")
            return
        }
        
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.rescaleAndCenterImageInScrollView(image: result.image)
            case .failure(let error):
                print("[SingleImageViewController]: Kingfisher error: \(error)")
                
                if let stub = UIImage(named: "Stub") {
                    self.imageView.image = stub
                    self.rescaleAndCenterImageInScrollView(image: stub)
                }
                self.showError()
            }
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

extension SingleImageViewController {
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let theoreticalScale = max(hScale, vScale)
        let scale = max(maxZoomScale, max(minZoomScale, theoreticalScale))
        scrollView.setZoomScale(scale, animated: true)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController {
    func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(
            title: "Не надо",
            style: .default) { _ in 
                alert.dismiss(animated: true)
            }
        
        let tryAgainAction = UIAlertAction(
            title: "Повторить",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.setImage()
            }
        
        alert.addAction(cancelAction)
        alert.addAction(tryAgainAction)
        
        present(alert, animated: true)
    }
}
