//
//  Search2CollectionViewCell.swift
//  Splash
//
//  Created by student on 2021/7/25.
//

import UIKit

class SearchImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "searchCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        self.imageView.sd_setImage(with: url, completed: nil)
//        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let data = data, error == nil else {
//                return
//            }
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                self?.imageView.image = image
//            }
//        }.resume()
    }
    
    
    
}
