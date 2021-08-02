//
//  ListTableViewCell.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit



protocol xxxDelegate: class {
    func showAlert_(title: String, message: String, timeToDissapear: Int, on ViewController: UIViewController) -> Void
}

class ListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    var completionHandler: ((String) -> Void)?
    var index: Int?
    var imageString: String?
    weak var delegate: xxxDelegate?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupElments()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    @IBAction func saveImagePressed(_ sender: Any) {
        
        print("Save Image")
        self.saveImageToAlbum(image: imageString!)
        let uiVC = UIViewController()
        self.delegate?.showAlert_(title: "Save", message: "", timeToDissapear: 2, on: uiVC)
//        if let imagestring = imageString {
//            completionHandler?(imagestring)
//        }
    }
    
    func setupElments() {
        self.listImageView.contentMode = .scaleAspectFill
        self.nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.nameLabel.textColor = UIColor.white
        let image = UIImage(systemName: "arrow.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .light))
        self.saveBtn.setImage(image, for: .normal)
    }
    
    
    func saveImageToAlbum(image: String) {
        let imageString = image
        if let url = URL(string: imageString) {
            let data = try? Data(contentsOf: url)
            let savedImage = UIImage(data: data!)
            UIImageWriteToSavedPhotosAlbum(savedImage!, nil, nil, nil)
            
        }
    }
    
    
    
    
    
    
}
