//
//  DetailViewController.swift
//  Splash
//
//  Created by student on 2021/7/24.
//

import UIKit
import SDWebImage
import SafariServices
import Loaf
import JGProgressHUD
import CoreData


//class Splash: NSManagedObject {
//
//    @NSManaged var imageURL: String?
//    @NSManaged var width: Int
//    @NSManaged var height: Int
//
//}


class DetailViewController: UIViewController, SFSafariViewControllerDelegate, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {

    
    //infoBtn
    @objc private let infoBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.backgroundColor = .black
        let image = UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .light))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        //Shadow
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.6
        //Corner Radius
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    
    
    //DownloadButton
    @objc private let downloadBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.backgroundColor = .white
        let image = UIImage(systemName: "arrow.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        //Shadow
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.6
        //Corner Radius
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    //ShareButton
    @objc private let shareBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.backgroundColor = .white
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        //Shadow
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.6
        //Corner Radius
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    //SaveButton
    @objc private let saveBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        button.backgroundColor = .white
        let image = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        //Shadow
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.6
        //Corner Radius
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    

    //AlertView
    @objc private let alertView: UIView = {
        let alert = UIView()
        alert.layer.masksToBounds = true
        alert.backgroundColor = .black
        alert.layer.cornerRadius = 13
        return alert
    }()
    
    //宣告一個名為mytargetView的UIView，取得ViewController.view
    var mytargetView: UIView?
    var uiVC: UIViewController?
    var imageDetail: [DetailData] = []
    
    

    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    var scrollView: UIScrollView!
    
    
    var photoDetails: PhotoData?
    var photoDetails2: Result?
    var photoDetails3: NSManagedObject?
    
       
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupPhotoDetail()
        //getImageEXIF(id: (photoDetails?.id)!)

        //隱藏Left bar item
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        // 隱藏TabBar
        self.tabBarController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        // 隱藏NavigationBar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        
        let vWidth = self.view.frame.width
        let vHeight = self.view.frame.height
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: vWidth, height: vHeight)
        //scrollImg.backgroundColor = UIColor(red: 90, green: 90, blue: 90, alpha: 0.90)
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGest)
        self.view.addSubview(scrollView)
        
        //imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: vWidth, height: vHeight))
        self.imageView.layer.cornerRadius = 11.0
        self.imageView.clipsToBounds = false
        scrollView.addSubview(imageView)
        
        //DownloadBtn
        view.addSubview(downloadBtn)
        downloadBtn.addTarget(self, action: #selector(downloadImage), for: .touchUpInside)
        
        //ShareBtn
        view.addSubview(shareBtn)
        shareBtn.addTarget(self, action: #selector(share), for: .touchUpInside)
        
        //SaveBtn
        view.addSubview(saveBtn)
        saveBtn.addTarget(self, action: #selector(addToCollection), for: .touchUpInside)
        
        //infoBtn
        view.addSubview(infoBtn)
        infoBtn.addTarget(self, action: #selector(presntImageInfoPage), for: .touchUpInside)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadBtn.frame = CGRect(x: view.frame.size.width - 70,
                                   y: view.frame.size.height - 120,
                                   width: 50, height: 50)
        
        shareBtn.frame = CGRect(x: view.frame.size.width - 70,
                                y: view.frame.size.height - 185,
                                width: 50, height: 50)
        
        saveBtn.frame = CGRect(x: view.frame.size.width - 70, y: view.frame.size.height - 250, width: 50, height: 50)
        
        infoBtn.frame = CGRect(x: view.frame.size.width - 380,
                               y: view.frame.size.height - 120,
                               width: 50, height: 50)
    }
    
    
    
    
    func setupPhotoDetail() {
        
        //From ListVC
        if let imageURL = photoDetails?.urls?.regular {
            self.imageView.sd_setImage(with: imageURL, completed: nil)
            self.imageView.frame.size.width = view.frame.size.width
        }
        
        //From SearchVC
        if let imageString = photoDetails2?.urls?.regular, let url = URL(string: imageString) {
            self.imageView.sd_setImage(with: url, completed: nil)
        }
        
        //From FavVC
        if let imageURL = URL(string: photoDetails3?.value(forKey: "imageURL") as? String ?? "") {
            self.imageView.sd_setImage(with: imageURL, completed: nil)
        }

    }
    

    
    @IBAction func closeBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    @objc func share() {
        let activityVC = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            // 如果錯誤存在，跳出錯誤視窗並顯示給使用者。
            if error != nil {
                self.showAlert_(title: "Error", message: "", timeToDissapear: 2, on: self)
                return
            }
            // 如果發送成功，跳出提示視窗顯示成功。
            if completed {
                self.showAlert_(title: "Done", message: "", timeToDissapear: 2, on: self)
            }
        }
        self.present(activityVC, animated: true, completion: nil)

    }
    
    
    
    @objc func downloadImage(_ sender: Any) {
        
        //From ListVC
        if let urlString = photoDetails?.urls?.raw {
            self.saveImageToAlbum(image: urlString)
        }
        
        //From SearchVC
        if let urlString = photoDetails2?.urls?.raw {
            self.saveImageToAlbum(image: urlString)
        }
        
        //From FavVC
        if let urlString = photoDetails3?.value(forKey: "imageURL") as? String {
            self.saveImageToAlbum(image: urlString)
        }
    }
    
    
    func saveImageToAlbum(image: String) {
        let imageString = image
        if let url = URL(string: imageString) {
            let data = try? Data(contentsOf: url)
            let savedImage = UIImage(data: data!)
            UIImageWriteToSavedPhotosAlbum(savedImage!, nil, nil, nil)
            //Loaf("Image successfully saved to your photos!", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
            self.showAlert_(title: "Save", message: "", timeToDissapear: 2, on: self)
        }
    }
    
    
    @objc func addToCollection() {
        
        //From ListVC
        if let url = photoDetails?.urls?.regular {
            let urlString = "\(url)"
            let width = photoDetails?.width
            let height = photoDetails?.height
            let id = (photoDetails?.id)!
            self.saveToCoreData(imageURL: urlString, width: width ?? 0, height: height ?? 0, id: id)
        }
        
        //From SearchVC
        if let url = photoDetails2?.urls?.regular {
            let urlString = "\(url)"
            let width = photoDetails2?.width
            let height = photoDetails2?.height
            let id = (photoDetails2?.id)!
            self.saveToCoreData(imageURL: urlString, width: width ?? 0, height: height ?? 0, id: id)
        }
        
        
        
        
        self.showAlert_(title: "Done", message: "", timeToDissapear: 2, on: self)
    }
    
    
    func saveToCoreData(imageURL: String, width: Int, height: Int, id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Splash", in: managedContext)
        let unsplash = NSManagedObject(entity: entity!, insertInto: managedContext)
        unsplash.setValue(imageURL, forKey: "imageURL")
        unsplash.setValue(width, forKey: "width")
        unsplash.setValue(height, forKey: "height")
        unsplash.setValue(id, forKey: "id")
        do {
            try managedContext.save()
            print("Data Saved Successfully!")
            print(imageURL)
            print(id)
            self.showAlert_(title: "Save", message: "", timeToDissapear: 2, on: self)
            //Loaf("Your image successfully added to your favorite!", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    @IBAction func sendTOAuthorWebsite(_ sender: Any) {
        
        if let authorWebsiteURL = photoDetails?.user?.links?.html, let url = URL(string: authorWebsiteURL) {
            let safari = SFSafariViewController(url: url)
            
            safari.delegate = self
            self.present(safari, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func showAlert_(title: String, message: String, timeToDissapear: Int, on ViewController: UIViewController) -> Void {
        guard let targetView = ViewController.view else{
            return
        }
        //取得目前ViewController.view
        mytargetView = targetView
        targetView.addSubview(alertView)
        //定義alertView長寬和位置
        alertView.frame = CGRect(x: view.frame.size.width/2 - 50,
                                 y: view.frame.size.height/2,
                                 width: 100, height: 80)
        alertView.backgroundColor = .black
        alertView.layer.opacity = 0.8
        //標題
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: 100, height: 80))
        //titleLabel.center.y = view.frame.size.height/2
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.backgroundColor = .black
        //標題文字為”title”之內容
        titleLabel.text = title
        //標題文字置中對齊
        titleLabel.textAlignment = .center
        //將標題titleLabel加入alertView中
        alertView.addSubview(titleLabel)
        
        //Setting the NSTimer to close the alert after timeToDissapear seconds.
        _ = Timer.scheduledTimer(timeInterval: Double(timeToDissapear), target: self, selector: #selector(dismissAlert), userInfo: nil, repeats: false)
    }
    
    
    //關閉視窗
    @objc func dismissAlert() {
        alertView.alpha = 0
//        guard let targetView = mytargetView else {
//            return
//        }
//        UIView.animate(withDuration: 0.25,
//                       animations: {
//                        //改alertView Y軸位置讓alertView滑出螢幕
//                        self.alertView.frame = CGRect(x: targetView.frame.size.width/2 - 50, y: targetView.frame.size.height, width: 100, height: 80)
//                       },completion: { done in
//                        if done{
//                            UIView.animate(withDuration: 0.25,animations: {
//
//                            }, completion: { done in
//                                if done{
//                                    //再清除UIView
//                                    //移除新增至alertView裡的所有物件
//                                    for child : UIView in self.alertView.subviews as [UIView]{
//                                        child.removeFromSuperview()
//                                    }
//                                    //移除alertview
//                                    self.alertView.removeFromSuperview()
//                                }
//                            })
//                        }
//                       })
    }
        
        
    
    @objc func presntImageInfoPage() {
        let presentVC = PresentDetailViewController()
        presentVC.modalPresentationStyle = .custom
        presentVC.transitioningDelegate = self
        presentVC.photoDetails = self.photoDetails
        presentVC.photoDetails2 = self.photoDetails2
        presentVC.photoDetails3 = self.photoDetails3
        self.present(presentVC, animated: true, completion: nil)
    }
    
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    
}
