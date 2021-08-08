//
//  ImageViewController.swift
//  Splash
//
//  Created by student on 2021/8/3.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var uiVC : ViewController?
    var depositList: [String] = []
    var typeIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = UIImage(named: "iphonex") {
            imageView.image = image
        }
    }
    

}
