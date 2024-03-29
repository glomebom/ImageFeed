//
//  ViewController.swift
//  ImageFeed
//
//  Created by Gleb on 29.02.2024.
//

import UIKit



final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let photoDate: Date = .init()
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверка идентификатора сегвея
        if segue.identifier == showSingleImageSegueIdentifier {
            // Преобразуем тип для свойства segue.destination (у него тип UIViewController) к тому, который мы ожидаем (выставлен в Storyboard)
            let viewController = segue.destination as! SingleImageViewController
            // Преобразуем тип для аргумента sender (ожидаем, что там будет indexPath)
            let indexPath = sender as! IndexPath
            // Получаем по индексу название картинки и саму картинку из ресурсов приложения
            let image = UIImage(named: photosName[indexPath.row])
            // Передаём эту картинку в imageView внутри SingleImageViewController
            viewController.image = image
        } else {
            // Если это неизвестный сегвей, есть вероятность, что он был определён суперклассом (то есть родительским классом). В таком случае мы должны передать ему управление
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ImagesListViewController: UITableViewDataSource {
    
    // Метод определяющий количество строк/ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    // По такому принципу этот метод работает для любой таблицы. Сначала нам нужно получить ячейку для определённой секции и позиции в секции, далее — привести её к нужному типу, чтобы работать с ячейкой, сконфигурировать её и вернуть ячейку из метода.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Метод, который из всех ячеек, зарегистрированных в таблице, возвращает ячейку по заранее добавленному идентификатору "ImagesListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reusedIdentifier, for: indexPath)
        
        // Чтобы работать с ячейкой как с экземпляром класса ImagesListCell, нам надо провести приведение типов
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        // Вызов метода конфигурации ячейки
        configCell(for: imagesListCell, with: indexPath)
        
        // Возвращаем ячейку во View
        return imagesListCell
    }
}

extension ImagesListViewController {
    
    // Метод конфигурации ячейки
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        // Название картинки по индексу ячейки
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        // Настраиваем элементы ячейки
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: photoDate)
        // Лайк для каждой ячейки с четным индексом
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "active") : UIImage(named: "not_active")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    // Настройка перехода через сегвей с конкретным идентификатором
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // Метод настройки размера ячейки в записимости от размеров image
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return .zero
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}
