//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Gleb on 11.05.2024.
//

import Foundation

final class ImagesListService {
    
    private enum GetUserDataError: Error {
        case invalidPhotoRequest
    }
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var mainUrlProfile = "https://api.unsplash.com/"
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    //    функция внутри себя определяет номер следующей страницы для закачки (номер не должен сообщаться извне, как параметр функции);
    //    если идёт закачка, то нового сетевого запроса не создаётся, а выполнение функции прерывается;
    //    при получении новых фотографий массив photos обновляется из главного потока, новые фото добавляются в конец массива;
    //    после обновления значения массива photos публикуется нотификация ImagesListService.DidChangeNotification.
    
    private init() {}
    
    private func makePhotoRequest(page: Int) -> URLRequest? {
        guard let url = URL(string: mainUrlProfile + "/photos?page=\(page)"),
              let token = OAuth2TokenStorage().token else {
            preconditionFailure("Error: unable to construct PhotoRequestUrl")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    private func fetchPhotosNextPage(page: Int, completion: @escaping (Result<Photo, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0)  + 1
        
        guard let requestWithPageNumber = makePhotoRequest(page: page) else {
            completion(.failure(GetUserDataError.invalidPhotoRequest))
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
                        createdAt: self.getDateFromString(dateString: dataOfPhoto.created_at),
                        welcomeDescription: dataOfPhoto.description,
                        thumbImageURL: dataOfPhoto.urls.thumb,
                        largeImageURL: dataOfPhoto.urls.full,
                        isLiked: dataOfPhoto.likedByUser
                    )
                    freshArrayOfPhotos.append(photo)
                }
                //completion(.success(decodedData))
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
                //completion(.failure(error))
                print("[ImagesListService]: \(error)")
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func getDateFromString(dateString: String?) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let dateString = dateString else {
            return nil
        }
        return formatter.date(from: dateString)
    }
}
