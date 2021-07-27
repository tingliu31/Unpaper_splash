//
//  ListCollectionViewCell.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    

    
   
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    

    
    func configure(with listURLString: String) {
        guard let url = URL(string: listURLString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let photodata = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: photodata)
                //let text = String(data: photodata, encoding: )
                
            
            }
        }.resume()
    }
    
    
}
