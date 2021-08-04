//
//  ListTableViewCell.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit
import JGProgressHUD



protocol xxxDelegate: class {
//    func test()
    func showAlert_(title: String, message: String, timeToDissapear: Int, on ViewController: UIViewController)
    
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
    var uiVC : ListViewController?
    var hud: JGProgressHUD?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupElments()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    @IBAction func saveImagePressed(_ sender: Any) {
        
//        hud = JGProgressHUD(style: .dark)
//        hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
//        hud?.show(in: (uiVC?.view)!, animated: true)
        
        self.saveImageToAlbum(image: imageString!)
        print("Download Image successful!!")
        
        //self.hud?.dismiss(animated: true)
        self.delegate?.showAlert_(title: "Save", message: "", timeToDissapear: 2, on: uiVC!)

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
