//
//  FavoriteCollectionViewCell.swift
//  Splash
//
//  Created by student on 2021/7/27.
//

import UIKit
import CoreData
import SDWebImage

class FavoriteCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "favoriteCell"
    var favoriteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(favorite: NSManagedObject) {
        guard let url = URL(string: favorite.value(forKey: "imageURL") as! String) else { return }
        favoriteImageView.layer.cornerRadius = 4.0
        favoriteImageView.layer.masksToBounds = true
        favoriteImageView.sd_setImage(with: url, completed: nil)
    }
    
}
