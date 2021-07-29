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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var highLightView: UIView!
    @IBOutlet weak var checkImage: UIImageView!
    
    
    override var isHighlighted: Bool {
        didSet {
            highLightView.isHidden = !isHighlighted
        }
    }
    
    override var isSelected: Bool {
        didSet {
            highLightView.isHidden = !isSelected
            checkImage.isHidden = !isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print()
    }
    
    func configureCell(favorite: NSManagedObject) {
        guard let url = URL(string: favorite.value(forKey: "imageURL") as! String) else { return }
        print(url)
        imageView.layer.cornerRadius = 4.0
        imageView.layer.masksToBounds = true
        imageView.sd_setImage(with: url, completed: nil)
    }
    
    
}
