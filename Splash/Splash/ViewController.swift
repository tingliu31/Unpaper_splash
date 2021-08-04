//
//  ViewController.swift
//  Splash
//
//  Created by student on 2021/7/22.
//

import UIKit
import SDWebImage
import MBProgressHUD



class ViewController: UIViewController, UIScrollViewDelegate {

    var photoDetail: [PhotoData] = []
    var imageScrollView: ImageScrollView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageURL: String?
    //private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        //scrollView.delegate = self
        
//        if let image = UIImage(named: "123") {
//            imageView.image = image
//        }


        
        
    }
    

    

    
    
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



