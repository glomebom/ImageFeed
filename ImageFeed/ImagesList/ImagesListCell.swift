//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Gleb on 06.03.2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reusedIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
