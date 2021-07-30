//
//  ListViewController.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit
import SDWebImage
import Lightbox
import JGProgressHUD


protocol ListLayoutCollectionViewFactoryDelegate: class {
    var photoData: [PhotoData]? { get set }
}



class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    enum ParamConstants {
        static let perPage: Int = 30
        static let orderBy: OrderBy = .latest
        static let contentFilter: ContentFilter = .high
        
        enum OrderBy: String {
            case relevant, latest
        }
        enum ContentFilter: String {
            case low, high
        }
    }
    
    
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
    var hud: JGProgressHUD?
    let queue = OperationQueue()
    var photoListData: [PhotoData] = []
    var lightBoxController: LightboxController?
    weak var delegate: ListLayoutCollectionViewFactoryDelegate?
    var refreshControl: UIRefreshControl!
    //var indexPage = 1
    
    
    required init?(coder aDecoder: NSCoder) {
        queue.maxConcurrentOperationCount = 10
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        hud = JGProgressHUD(style: .extraLight)
        hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud?.show(in: view, animated: true)
        updateUI()
        
        refreshControl = UIRefreshControl()
        
        //refreshControl.addTarget(self, action: #selector(refreshPhotoListData), for: UIControl.Event.valueChanged)
    }
    
    
    func updateUI() {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Splash"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.alpha = 0.8
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        
        loading()
        //getPhotoListData(page: indexPage)

    }
    
    @IBAction func refreshData(_ sender: Any) {
        
        hud = JGProgressHUD(style: .extraLight)
        hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud?.show(in: view, animated: true)
        refreshPhotoListData()
        //getPhotoListData(page: 1)
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.cellForRow(at: indexPath)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoListData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? ListTableViewCell else {
            fatalError("Could not dequeue a cell")
        }
        
//        cell.imageView?.image = nil //可能被reuse，所以要把之前的照片先清除 否殘看到殘影
//        if let imageURL = self.photoListData[indexPath.row].urls?.regular,
//           let name = self.photoListData[indexPath.row].user?.name {
//            let operation = ImageOperation(url: imageURL, String: name, indexPath: indexPath, tableView: tableView)
//            self.queue.addOperation(operation)
//        }
        
        configure(cell: cell, indexPath: indexPath)
        return cell
        
    }
    
    
    // Setup the cell content
    func configure(cell: ListTableViewCell, indexPath: IndexPath) {
        //set up the image
        if let imageURL = self.photoListData[indexPath.row].urls?.regular {
            cell.listImageView.sd_setImage(with: imageURL, completed: nil)
            //cell.listImageView.downloadedFrom(url: imageURL)
            
            //Set up the author name Lable
            let name = self.photoListData[indexPath.row].user?.name
            cell.nameLabel.text = "\(name!)"

        }
    }
    
 
    //傳送資料到下一頁 DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            destination.photoDetails = photoListData[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    // Setup the height For Row, by image size
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // height圖片的高
        var rowHight = (Float(self.photoListData[indexPath.row].height!) * 0.1)
        if rowHight < 250 {
            rowHight = 250
        }
        return CGFloat(rowHight)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //取得所有的operation
        for op in self.queue.operations {
            if let operation = op as? ImageOperation, operation.indexPath == indexPath {
                //如果位置離開畫面，取消下載
                operation.cancel()  //operation.cancel = true
            }
        }
    }
    
    //判斷畫面是否滑到最下面
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableView.frame.height else {return}
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            page += 1
            print("page: \(page)")
            getPhotoListData(page: page)
        }
    }
    
    
    // page的初始值
    var page : Int = 0
    func loading(){
        if page < 2 {
            page += 1
            print("page: \(page)")
             //test(page: page)
            getPhotoListData(page: page)
        }
    }
    
   
    // GetDataFromJson
    func getPhotoListData(page: Int) {
        // 1. 每30筆就跑下一頁
        // 2. 所以當資料30的時候要重跑一次func
        // 3. 會有一個存在最外圍的資料
        
        let baseURL = "https://api.unsplash.com/photos?client_id=ujAYBJVDy9u57y3nJsLVr-byAW6bRoCXuLAjnd0OANo"
        let apiString = baseURL + "&page=\(page)" + "&per_page=\(ParamConstants.perPage)" + "&order_by=\(ParamConstants.orderBy)"
        print("apiString: \(apiString)")
        
        if let listURLString = URL(string: apiString) {
            
            let task = URLSession.shared.dataTask(with: listURLString) { (data, response, error) in
                if let photoData = data, let dataList = try? JSONDecoder().decode([PhotoData].self, from: photoData) {
                    print("Got jsonData successful!!!")
                    //self.photoListData = dataList
                    for data in dataList {
                        self.photoListData.append(data)
                    }
                    print("photoListData count: \(self.photoListData.count)")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.hud?.dismiss(animated: true)
                    }
                } else {
                    print("Decode error: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }
    
    
    
    @objc func refreshPhotoListData() {
        let baseURL = "https://api.unsplash.com/photos?client_id=ujAYBJVDy9u57y3nJsLVr-byAW6bRoCXuLAjnd0OANo"
        let apiString = baseURL + "&page=1" + "&per_page=\(ParamConstants.perPage)" + "&order_by=\(ParamConstants.orderBy)"
        print("apiString: \(apiString)")
        
        if let listURLString = URL(string: apiString) {
            
            let task = URLSession.shared.dataTask(with: listURLString) { (data, response, error) in
                if let photoData = data, let dataList = try? JSONDecoder().decode([PhotoData].self, from: photoData) {
                    print("Refresh jsonData successful!!!")

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        
                        self.photoListData = dataList
                        print("photoListData count: \(self.photoListData.count)")
                        self.tableView.reloadData()
                        self.hud?.dismiss(animated: true)
                    }
                } else {
                    print("Decode error: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }

    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//
//        if (offsetY > contentHeight - scrollView.frame.height * 4) {
//            indexPage = 2
//            getPhotoListData(page: indexPage)
//        }
//    }
    
    
  

    
}
