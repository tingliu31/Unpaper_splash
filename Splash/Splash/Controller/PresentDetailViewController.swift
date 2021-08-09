//
//  PresentDetailViewController.swift
//  Splash
//
//  Created by student on 2021/7/30.
//

import UIKit
import CoreData
import MapKit
import SafariServices

class PresentDetailViewController: UIViewController, MKMapViewDelegate, SFSafariViewControllerDelegate {

    
    var imageInfo: DetailData?
    var photoDetails: PhotoData?
    var photoDetails2: Result?
    var photoDetails3: NSManagedObject?
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var managedContext: NSManagedObjectContext?
    var id: String?
    var favoriteItems = [NSManagedObject]()
    
    var myMapView :MKMapView!
    let annotation = MKPointAnnotation()
    
    
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLable: UILabel!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var apertureLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpImage()
        getImageEXIF()
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        //self.slideView.roundCorners(.allCorners, radius: 5)
        
        /*
        myMapView = MKMapView(frame: CGRect(x: 40, y:410 , width: self.view.frame.width - 80, height: 150))
        myMapView.delegate = self
        myMapView.mapType = .standard
        myMapView.isZoomEnabled = true
        view.addSubview(myMapView)
        myMapView.isHidden = true
        */
        
        self.cityLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(navigateToMap))
        self.cityLabel.addGestureRecognizer(tap)
        
        
        self.imageView.isUserInteractionEnabled = true
        let tap_ = UITapGestureRecognizer(target: self, action: #selector(navigateToWebsite))
        self.imageView.addGestureRecognizer(tap_)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }


    @objc func navigateToMap() {
        if ( CLLocationCoordinate2DIsValid(self.annotation.coordinate)) {
            //self.cityLabel.textColor = .blue
            let placemark = MKPlacemark(coordinate: self.annotation.coordinate)
            let item = MKMapItem(placemark: placemark)
            item.name = self.imageInfo?.location?.name
            item.openInMaps(launchOptions: nil)
        }
    }
    
    
    @objc func navigateToWebsite() {
        
        //From List
        if let websiteString = photoDetails?.user?.links?.html,
           let url = URL(string: websiteString) {
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            self.present(safari, animated: true, completion: nil)
        } else if let websiteString = photoDetails2?.user?.links?.html,
                  let url = URL(string: websiteString) {
            //From Search
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            self.present(safari, animated: true, completion: nil)
        } else {
            //From Fav
            if let websiteString = photoDetails3?.value(forKey: "website") as? String,
               let url = URL(string: websiteString) {
                let safari = SFSafariViewController(url: url)
                safari.delegate = self
                self.present(safari, animated: true, completion: nil)
            }
            
            
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
    
    
    
    func setUpImage() {
        
        //From List
        if let imageString = self.photoDetails?.user?.profile_image?.medium, let url = URL(string: imageString) {
            self.imageView.sd_setImage(with: url, completed: nil)
            self.imageView.layer.cornerRadius = 25
            self.nameLabel.text = self.photoDetails?.user?.name
        } else if let imageString = self.photoDetails2?.user?.profile_image?.medium, let url = URL(string: imageString) {
            //From Search
            self.imageView.sd_setImage(with: url, completed: nil)
            self.imageView.layer.cornerRadius = 25
            self.nameLabel.text = self.photoDetails2?.user?.name
        } else {
            //From Fav
            if let imageString = self.photoDetails3?.value(forKey: "userImage") as? String,
               let url = URL(string: imageString) {
                self.imageView.sd_setImage(with: url, completed: nil)
                self.imageView.layer.cornerRadius = 25
                self.nameLabel.text = self.photoDetails3?.value(forKey: "name") as? String
            }
        }
        

    }
    
    

    func getFavoriteID() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Splash")
        do {
            let unsplash = try managedContext?.fetch(fetchRequest)
            //idFromCore =
            for data in unsplash! {
                self.photoDetails3 = data
            }

        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    
    func getImageEXIF() {
        //let id = (photoDetails?.id)!
        
        if let imageID = photoDetails?.id {
            self.id = imageID
        } else if let imageID = photoDetails2?.id {
            self.id = imageID
//            getFavoriteID()
//            let imageID = object?.value(forKey: "id") as? String
//            self.id = imageID
        } else {
            let imageID = photoDetails3?.value(forKey: "id") as? String
            self.id = imageID
        }
        
        print("-------------------------")
        let baseURL = "https://api.unsplash.com/photos/\(self.id ?? "")?client_id=ujAYBJVDy9u57y3nJsLVr-byAW6bRoCXuLAjnd0OANo"
        
        print(baseURL)
        print("id: \(self.id ?? "")")
        
        guard let url = URL(string: baseURL) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let datailData = data, error == nil else {
                return
            }
            do{
                let jasonResult = try JSONDecoder().decode(DetailData.self, from: datailData)
                print("Got Detail jsonResult !!!")
                print("-------------------------")
                self.imageInfo = jasonResult
                DispatchQueue.main.async {
                    
                    //if let imageString = self.imageInfo
                    
                    
                    self.dimensionsLabel.text = String((self.imageInfo?.width)!) + " x " + String((self.imageInfo?.height)!)
                    self.makeLabel.text = self.imageInfo?.exif?.make ?? "_"
                    self.modelLable.text = self.imageInfo?.exif?.model ?? "_"
                    self.lengthLabel.text = self.imageInfo?.exif?.focalLength ?? "_"
                    
                    self.timeLabel.text = self.imageInfo?.created_at ?? "_"
                    self.timeLabel.lineBreakMode = NSLineBreakMode.byClipping
                    
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
                    
                    
                    //Location
                    if self.imageInfo?.location?.title != nil {
                        self.cityLabel.text = self.imageInfo?.location?.title
                        print("title: \(String(describing: self.imageInfo?.location?.title))")
                        self.annotation.title = self.imageInfo?.location?.title
                    } else {
                        self.cityLabel.text = "_"
                    }
                    
                    
                    //地圖myMapView
                    if self.imageInfo?.location?.position?.latitude != nil && self.imageInfo?.location?.position?.longitude != nil {
                        //底線
                        self.cityLabel.underline()
                        //self.myMapView.isHidden = false
                        let latitude = self.imageInfo?.location?.position?.latitude
                        let longitude = self.imageInfo?.location?.position?.longitude
                        print("latitude:", String(latitude!) + ", longitude:" +  String(longitude!)  )
                        
                        //設置位置
                        self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                        
//                        self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
//                                                let placemark = MKPlacemark(coordinate: self.annotation.coordinate)
//                                                let item = MKMapItem(placemark: placemark)
//                                                item.name = self.imageInfo?.location?.city
//                                                item.openInMaps(launchOptions: nil)
                        
//                        self.myMapView.setCenter(self.annotation.coordinate, animated: true)
//                        self.myMapView.setRegion(MKCoordinateRegion(center: self.annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200), animated: true)
//                        self.myMapView.addAnnotation(self.annotation)
                        
                    }
                }
            }catch{
                print("Detail Decode error: \(error)")
            }
        }
        task.resume()
    }
    
    
}



extension UILabel {
    func underline() {
        if let textUnwrapped = self.text {
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let underlineAttributedString = NSAttributedString(string: textUnwrapped, attributes: underlineAttribute)
            self.attributedText = underlineAttributedString
        }
    }
}
