//
//  SearchPeopleTableViewCell.swift
//  Splash
//
//  Created by student on 2021/8/1.
//

import UIKit

class SearchPeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var igLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
                self?.userImageView.image = image
                self?.userImageView.layer.cornerRadius = 35
            }
        }.resume()
    }
    
    
    func configure_(urlString: String) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        self.userImageView.sd_setImage(with: url, completed: nil)
        //self.userImageView.image =
        //self.userImageView.layer.cornerRadius = 35
        
    }
    

}
