//
//  SearchCollectionViewCell.swift
//  Splash
//
//  Created by student on 2021/7/24.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    
        static let identifier = "searchCollectionViewCell"
        
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
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self?.imageView.image = image
                }
            }.resume()
        }
    
    
    
    
    
}
