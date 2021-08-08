//
//  ViewController.swift
//  Splash
//
//  Created by student on 2021/7/22.
//

import UIKit
import SDWebImage
import MapKit



class ViewController: UIViewController, MKMapViewDelegate, UIScrollViewDelegate {
    

    var photoDetail: [PhotoData] = []
    var imageURL: String?

    var scrollView: UIScrollView!
    var imageView: UIImageView!


    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
        
        
        //imageView = UIImageView(image: UIImage(named: "123"))
        let string = "https://images.unsplash.com/photo-1628258102957-1b77367c8c6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNDg3NDh8MHwxfGFsbHwyNHx8fHx8fDJ8fDE2Mjg0NDk0MTk&ixlib=rb-1.2.1&q=80&w=1080"
        
        if let imageURL = URL(string: string)  {
            if let imageData = try? Data(contentsOf: imageURL) {
                let image  = UIImage(data: imageData)
                self.imageView = UIImageView(image: image)
            }
        }
        
        
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.backgroundColor = UIColor.yellow
        //contentSize滾動區域 = 設定跟圖像視圖（2000×1500）大小相同
        scrollView.contentSize = imageView.frame.size
        //scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //滾動視圖邊界點
        //scrollView.contentOffset = CGPoint(x: 1000, y: 450)
    
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.delegate = self
        setupGestureRecognizer()
        
//        scrollView.minimumZoomScale = 0.1
//        scrollView.maximumZoomScale = 4.0
//        scrollView.zoomScale = 1.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //隱藏Left bar item
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        // 隱藏TabBar
        self.tabBarController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true
        // 隱藏NavigationBar
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateZoomSizeFor(size: view.frame.size)
    }

    func updateZoomSizeFor(size: CGSize) {
        let widthScale = size.width / imageView.frame.width
        let heightScale = size.height / imageView.frame.height
        let scale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = max(widthScale, heightScale)
        scrollView.zoomScale = scale
    }

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let inset = (scrollView.frame.height - imageView.frame.height) / 2
        scrollView.contentInset = .init(top: max(inset, 0), left: 0, bottom: 0, right: 0)
        
//        let imageViewSize = imageView.frame.size
//        let scrollViewSize = scrollView.bounds.size
//
//        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//
//        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    
    //使用滾動視圖與圖像視圖比來計算最小縮放因子
    //移除maximumZoomScale的設定，所以它被設定為預設值1.0
//    func setZoomScale() {
//        let imageViewSize = imageView.bounds.size
//        let scrollViewSize = scrollView.bounds.size
//        let widthScale = scrollViewSize.width / imageViewSize.width
//        let heightScale = scrollViewSize.height / imageViewSize.height
//
//        scrollView.minimumZoomScale = min(widthScale, heightScale)
//        scrollView.zoomScale = 1.0
//    }
    
    
    
    //每次縮放後被呼叫
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        let imageViewSize = imageView.frame.size
//        let scrollViewSize = scrollView.bounds.size
//
//        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//
//        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
//    }
    
    
    
//    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
//        if scrollView.zoomScale == 1 {
//            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
//
//        } else {
//            scrollView.setZoomScale(1, animated: true)
//        }
//    }
    
    
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {

        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    
    
//
//
//    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }


    
    //URLRequest
    //    func getPhotoListData() {
    //        if let photoListUrl = URL(string: "https://api.unsplash.com/photos?client_id=W3yce0SFSW1yllKPYe6gOInwIjp8DLBJGc8UE9Aweb4&page=1&per_page=30&order_by=latest") {
    //            let request = URLRequest(url: photoListUrl)
    //            let session = URLSession.shared
    //
    //            let task = session.dataTask(with: request) { data, response, error in
    //                if let error = error {
    //                    print("DataTask Request Error: \(error)")
    //                    return
    //                }
    //                guard let reponseData = data else {
    //                    return
    //                }
    //                do{
    //                    let decoder = JSONDecoder()
    //                    self.photoData = try decoder.decode([PhotoData].self, from: reponseData)
    //                    print("photoData: \(self.photoData)")
    //                }catch{
//                    print("Decoder Fail")
//                }
//            }
//            task.resume()
//        }
//    }
    
    
    //url
    func getData() {
        if let photoListUrl = URL(string: "https://api.unsplash.com/photos?client_id=W3yce0SFSW1yllKPYe6gOInwIjp8DLBJGc8UE9Aweb4&page=1&per_page=10&order_by=latest") {
            let task = URLSession.shared.dataTask(with: photoListUrl) { (data, response, error) in
                if let photoData = data, let dataList = try? JSONDecoder().decode( [PhotoData].self, from: photoData) {

                    print(dataList.count)
                    for i in dataList {
                        self.photoDetail.append(i)
                    }
                    print("--------------")
                    print(self.photoDetail.count)
                } else {
                    print("Decoder error: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }
    
   
    

}




