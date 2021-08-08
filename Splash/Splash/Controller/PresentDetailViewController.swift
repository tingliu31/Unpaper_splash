//
//  PresentDetailViewController.swift
//  Splash
//
//  Created by student on 2021/7/30.
//

import UIKit
import CoreData
import MapKit

class PresentDetailViewController: UIViewController, MKMapViewDelegate {

    
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
    
    var aa: PresentationController?
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getImageEXIF()
        //setUpImageDetails()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        //self.slideView.roundCorners(.allCorners, radius: 5)
        
        
        myMapView = MKMapView(frame: CGRect(x: 40, y:410 , width: self.view.frame.width - 80, height: 150))
        myMapView.delegate = self
        myMapView.mapType = .standard
        myMapView.isZoomEnabled = true
        view.addSubview(myMapView)
        myMapView.isHidden = true
        
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
        self.timeLabel.text = imageInfo?.created_at ?? "_"
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
                self.imageInfo = jasonResult
                DispatchQueue.main.async {
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
                    if self.imageInfo?.location?.city != nil {
                        self.cityLabel.text = self.imageInfo?.location?.city
                        self.annotation.title = self.imageInfo?.location?.city
                    } else {
                        self.cityLabel.text = "_"
                    }
                    
                    if self.imageInfo?.location?.country != nil && self.imageInfo?.location?.city != nil {
                        self.cityLabel.text = (self.imageInfo?.location?.city)! + ", " + (self.imageInfo?.location?.country)!
                        self.annotation.subtitle = self.imageInfo?.location?.country
                    } else {
                        self.cityLabel.text = "_"
                    }
                    
                    //地圖myMapView
                    if self.imageInfo?.location?.position?.latitude != nil && self.imageInfo?.location?.position?.longitude != nil {
                        let latitude = self.imageInfo?.location?.position?.latitude
                        let longitude = self.imageInfo?.location?.position?.longitude
                        print("latitude:", String(latitude!) + ", longitude:" +  String(longitude!)  )
                        
                        //設置位置
                        self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                        
                        self.myMapView.setCenter(self.annotation.coordinate, animated: true)
                        self.myMapView.setRegion(MKCoordinateRegion(center: self.annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200), animated: true)
                        self.myMapView.addAnnotation(self.annotation)
                        
                        
                        self.myMapView.isHidden = false
                        
                        self.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 800)
                        
                    }
                }
            }catch{
                print("Detail Decode error: \(error)")
            }
        }
        task.resume()
    }
    
    
    
    
    
    
}
