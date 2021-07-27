//
//  ListTableViewCell.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupElments()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setupElments() {
        self.listImageView.contentMode = .scaleAspectFill
        self.nameLabel.font = UIFont.systemFont(ofSize: 14.0)
        self.nameLabel.textColor = UIColor.white
    }
    
    
    
    
    
}
