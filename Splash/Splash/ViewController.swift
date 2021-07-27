//
//  ViewController.swift
//  Splash
//
//  Created by student on 2021/7/22.
//

import UIKit




class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var photoData : [PhotoData] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getPhotoListData()
        getData()
        print("what-------------")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateZoomSizeFor(size: view.bounds.size)
    }
    
    func updateZoomSizeFor(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let scale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        scrollView.maximumZoomScale = max(widthScale, heightScale)
        scrollView.zoomScale = scale
    }
    
    
    @IBAction func tapZoom(_ sender: Any) {
        let size = view.bounds.size
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let scale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        scrollView.maximumZoomScale = max(widthScale, heightScale)
        scrollView.zoomScale = scale
    }
    
    
//    func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
//        if scrollView.zoomScale == 1 {
//            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
//        } else {
//            scrollView.setZoomScale(1, animated: true)
//        }
//    }
    
    
    //URLRequest
    func getPhotoListData() {
        if let photoListUrl = URL(string: "https://api.unsplash.com/photos?client_id=W3yce0SFSW1yllKPYe6gOInwIjp8DLBJGc8UE9Aweb4&page=1&per_page=30&order_by=latest") {
            let request = URLRequest(url: photoListUrl)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("DataTask Request Error: \(error)")
                    return
                }
                guard let reponseData = data else {
                    return
                }
                do{
                    let decoder = JSONDecoder()
                    self.photoData = try decoder.decode([PhotoData].self, from: reponseData)
                    print("photoData: \(self.photoData)")
                }catch{
                    print("Decoder Fail")
                }
            }
            task.resume()
        }
    }
    
    
    //url
    func getData() {
        if let photoListUrl = URL(string: "https://api.unsplash.com/photos?client_id=W3yce0SFSW1yllKPYe6gOInwIjp8DLBJGc8UE9Aweb4&page=1&per_page=30&order_by=latest") {
            let task = URLSession.shared.dataTask(with: photoListUrl) { (data, response, error) in
                if let photoData = data, let dataList = try? JSONDecoder().decode( [PhotoData].self, from: photoData) {
                   
                    print(dataList.count)
                    for everydata in dataList {
                        print(everydata.user?.name)
                    }
                    
                    
                } else {
                    print("Decoder error: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }
    
   
    

}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let inset = (scrollView.bounds.height - imageView.frame.height) / 2
            scrollView.contentInset = .init(top: max(inset, 0), left: 0, bottom: 0, right: 0)
           
    }
    
}
