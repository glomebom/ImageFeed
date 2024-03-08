//
//  ViewController.swift
//  ImageFeed
//
//  Created by Gleb on 29.02.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    // Массив в наименованиями изображений
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // Метод форматирования даты
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
        return photosName.count
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
        cell.dateLabel.text = dateFormatter.string(from: Date())
        // Лайк для каждой ячейки с четным индексом
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "active") : UIImage(named: "not_active")
        cell.likeButton.setImage(likeImage, for: .normal)
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    // Метод настройки размера ячейки в записимости от размеров image
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}
