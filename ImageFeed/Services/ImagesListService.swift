//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Gleb on 11.05.2024.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
        
    private let dateFormatterISO8601 = ISO8601DateFormatter()
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var mainUrlProfile = "https://api.unsplash.com/"
    
    private init() {}
    
    private func makePhotoRequest(page: Int) -> URLRequest? {
        guard let url = URL(string: mainUrlProfile + "/photos?page=\(page)"),
              let token = OAuth2TokenStorage().token else {
            preconditionFailure("[ImagesListService]: Error: unable to construct PhotoRequestUrl")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0)  + 1
        
        guard let requestWithPageNumber = makePhotoRequest(page: nextPage) else {
            print("[ImagesListService]: error in requestWithPageNumber")
            return
        }
        
        let task = URLSession.shared.objectTask(for: requestWithPageNumber) { (result: Result<[PhotoResult],Error>) in
            switch result {
            case .success(let decodedData):
                var freshArrayOfPhotos: [Photo] = []
                decodedData.forEach { dataOfPhoto in
                    let photo = Photo(
                        id: dataOfPhoto.id,
                        size: CGSize(width: dataOfPhoto.width, height: dataOfPhoto.height),
                        createdAt: self.dateFormatterISO8601.date(from: dataOfPhoto.createdAt ?? ""),
                        welcomeDescription: dataOfPhoto.description,
                        thumbImageURL: dataOfPhoto.urls.thumb,
                        largeImageURL: dataOfPhoto.urls.full,
                        isLiked: dataOfPhoto.likedByUser
                    )
                    freshArrayOfPhotos.append(photo)
                }
                DispatchQueue.main.async {
                    self.photos += freshArrayOfPhotos
                    self.lastLoadedPage = nextPage
                    self.task = nil
                    NotificationCenter.default
                        .post(name: ImagesListService.didChangeNotification,
                              object: self,
                              userInfo: ["URL": decodedData])
                }
            case .failure(let error):
                print("[ImagesListService]: \(error)")
                self.task = nil
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    // Метод смены лайка
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard task == nil else { return }
        
        guard var likePhotoRequestUrl = likePhotoRequest(photoId: photoId) else {
            preconditionFailure("[ImagesListService]: Error: unable to construct url in func changeLike() ")
        }
        
        likePhotoRequestUrl.httpMethod = isLike ? "DELETE" : "POST"
        
        let task = URLSession.shared.objectTask(for: likePhotoRequestUrl) { [weak self] (result: Result<LikeResult,Error>) in
            
            guard let self = self else {
                print("[ImagesListService]: Error: changeLike URLSession.shared.objectTask error")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
                print("[ImagesListService]: Error: changeLike error - \(String(describing: error))")
                self.task = nil
            }
            self.task = nil
        }
        task.resume()
    }
    
    // Запрос статуса лайка фото
    private func likePhotoRequest(photoId: String) -> URLRequest? {
        guard let url = URL(string: mainUrlProfile + "photos/\(photoId)/like"),
              let token = OAuth2TokenStorage().token else {
            preconditionFailure("[ImagesListService]: Error: unable to construct likePhotoRequest")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func cleanPhotos() {
        photos = []
    }
}
