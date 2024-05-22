//
//  ViewController.swift
//  ImageFeed
//
//  Created by Gleb on 29.02.2024.
//

import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    @IBOutlet private var tableView: UITableView!
    
    private let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale.init(identifier: "RU")
        return formatter
    }()
    
    var presenter: ImagesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter = ImagesListPresenter(view: self)
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        presenter?.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let imageURL = photos[indexPath.row].largeImageURL
            viewController.setImageURL(imageURL: imageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reusedIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)
        
        let thumbImageUrl = photos[indexPath.row].thumbImageURL
        
        guard let url = URL(string: thumbImageUrl),
              let imageView = imagesListCell.cellImage else {
            return imagesListCell
        }
        
        imagesListCell.delegate = self
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url) { result in
            switch result {
            case .success(_):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("[ImagesListViewController]: \(error)")
            }
        }
        return imagesListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        var dateLabel: String
        if indexPath.row < photos.count {
            guard let image = UIImage(named: "Stub") else { return }
            if let date = photos[indexPath.row].createdAt {
                dateLabel = dateFormatter.string(from: date)
            } else {
                dateLabel = ""
            }
            let isLiked = photos[indexPath.row].isLiked
            
            cell.setImageCell(image: image, date: dateLabel, isLiked: isLiked)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = photos[indexPath.row].size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell, completion: @escaping (Bool) -> Void) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            
            guard let self = self else {
                print("[ImagesListViewController]: Error in imagesListService.changeLike")
                return
            }
            
            switch result {
            case .success():
                self.photos = imagesListService.photos
                let like = self.photos[indexPath.row].isLiked
                UIBlockingProgressHUD.dismiss()
                completion(like)
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                print("[ImagesListViewController]: ImagesListCellDelegate error: \(result)")
            }
        }
    }
}

extension ImagesListViewController {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}
