//
//  PresentDetailViewController.swift
//  Splash
//
//  Created by student on 2021/7/30.
//

import UIKit

class PresentDetailViewController: UIViewController {

    
    var imageInfo: DetailData?
    var photoDetails: PhotoData?
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLable: UILabel!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var apertureLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getImageEXIF(id: (photoDetails?.id)!)
        //setUpImageDetails()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        //self.slideView.roundCorners(.allCorners, radius: 5)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }



    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    
    
    func setUpImageDetails() {
        
        self.dimensionsLabel.text = String((imageInfo?.width)!) + "x" + String((imageInfo?.height)!)
        self.makeLabel.text = imageInfo?.exif?.make ?? "_"
        self.modelLable.text = imageInfo?.exif?.model ?? "_"
        self.isoLabel.text = String(imageInfo?.exif?.model ?? "_")
        self.lengthLabel.text = imageInfo?.exif?.focalLength ?? "_"
        self.apertureLabel.text = imageInfo?.exif?.aperture ?? "_"
        self.speedLabel.text = imageInfo?.exif?.exposureTime ?? "_"
        
    }
    
    
    
    
    
    
    func getImageEXIF(id: String) {
        let id = (photoDetails?.id)!
        let baseURL = "https://api.unsplash.com/photos/\(id)?client_id=ujAYBJVDy9u57y3nJsLVr-byAW6bRoCXuLAjnd0OANo"
        
        print(baseURL)
        
        guard let url = URL(string: baseURL) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let datailData = data, error == nil else {
                return
            }
            do{
                let jasonResult = try JSONDecoder().decode(DetailData.self, from: datailData)
                print("Got Detail jsonResult !!!")
                self.imageInfo = jasonResult
                DispatchQueue.main.async {
                    self.dimensionsLabel.text = String((self.imageInfo?.width)!) + " x " + String((self.imageInfo?.height)!)
                    self.makeLabel.text = self.imageInfo?.exif?.make ?? "_"
                    self.modelLable.text = self.imageInfo?.exif?.model ?? "_"
                    self.lengthLabel.text = self.imageInfo?.exif?.focalLength ?? "_"
                    
                    let isoString = self.imageInfo?.exif?.iso
                    if String(isoString ?? 0) == "0" {
                        self.isoLabel.text = "_"
                    } else {
                        self.isoLabel.text = String((self.imageInfo?.exif?.iso)!)
                    }
                    
                    if self.imageInfo?.exif?.aperture != nil {
                        self.apertureLabel.text = "f/" + (self.imageInfo?.exif?.aperture)!
                    } else {
                        self.apertureLabel.text = "_"
                    }
                    //self.apertureLabel.text = self.imageInfo?.exif?.aperture ?? "_"
                    
                    if self.imageInfo?.exif?.exposureTime != nil {
                        self.speedLabel.text = (self.imageInfo?.exif?.exposureTime)! + "s"
                    }else{
                        self.speedLabel.text = "_"
                    }
                    //self.speedLabel.text = self.imageInfo?.exif?.exposureTime ?? "_"
                    
                    
                }
                
            }catch{
                print("Detail Decode error: \(error)")
            }
        }
        task.resume()
    }
    
    
    
    
}
