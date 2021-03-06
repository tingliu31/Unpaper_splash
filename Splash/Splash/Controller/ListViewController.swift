//
//  ListViewController.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit
import SDWebImage
import JGProgressHUD



class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShowAlertDelegate {
    
    
    
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
    
    
    
    var page : Int = 0
    var sss: String?
    var hud: JGProgressHUD?
    let queue = OperationQueue()
    var photoListData: [PhotoData] = []
    //var refreshControl: UIRefreshControl!
    
    var mytargetView: UIView?
    
    
    //AlertView
    @objc private let alertView: UIView = {
        let alert = UIView()
        alert.layer.masksToBounds = true
        alert.backgroundColor = .black
        alert.layer.cornerRadius = 13
        return alert
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //overrideUserInterfaceStyle = .light
        hud = JGProgressHUD(style: .extraLight)
        hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud?.show(in: view, animated: true)
        updateUI()
        
        print(NSHomeDirectory())
        //refreshControl = UIRefreshControl()
        
        
    }
    
    
    func updateUI() {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Unpaper"
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.alpha = 0.8
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.tableView.showsVerticalScrollIndicator = false
        if #available(iOS 11, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.tableView.estimatedSectionHeaderHeight = 0.01
        
        
        
        self.tableView.reloadData()
        
        //loading()
        getPhotoListData(page: page)
        
    }
    
    
    
    @objc func downloadImagePressed(_ sender: Any, indexPath: IndexPath) {
        
        if let imageURL = self.photoListData[indexPath.row].urls?.regular {
            let imageString = "\(imageURL)"
            self.saveImageToAlbum(image: imageString)
        }
    }
    
    
    
    @IBAction func refreshData(_ sender: Any) {
        
        
        refreshPhotoListData()
        //refreshControl = UIRefreshControl()
        //tableView.addSubview(refreshControl)
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
        
        //        cell.imageView?.image = nil //?????????reuse??????????????????????????????????????? ??????????????????
        //        if let imageURL = self.photoListData[indexPath.row].urls?.regular,
        //           let name = self.photoListData[indexPath.row].user?.name {
        //            let operation = ImageOperation(url: imageURL, String: name, indexPath: indexPath, tableView: tableView)
        //            self.queue.addOperation(operation)
        //        }
        
        configure(cell: cell, indexPath: indexPath)
        cell.index = indexPath.row
        cell.imageString = self.photoListData[indexPath.row].urls?.raw
        cell.delegate = self
        cell.uiVC = self
        
        
        
        
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
    
    
    
    //???????????????????????? DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            destination.photoDetails = photoListData[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    
    // Setup the height For Row, by image size
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // height????????????
        var rowHight = (Float(self.photoListData[indexPath.row].height!) * 0.1)
        if rowHight < 250 {
            rowHight = 250
        }
        return CGFloat(rowHight)
    }
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //???????????????operation
        for op in self.queue.operations {
            if let operation = op as? ImageOperation, operation.indexPath == indexPath {
                //???????????????????????????????????????
                operation.cancel()  //operation.cancel = true
            }
        }
    }
    
    
    //?????????????????????????????????
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > self.tableView.frame.height else {return}
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            page += 1
            print("page: \(page)")
            getPhotoListData(page: page)
        }
    }
    
    
    // page????????????
    //    var page : Int = 0
    //    func loading(){
    //        if page < 2 {
    //            page += 1
    //            print("page: \(page)")
    //             //test(page: page)
    //            getPhotoListData(page: page)
    //        }
    //    }
    
    
    
    // GetDataFromJson
    func getPhotoListData(page: Int) {
        // 1. ???30??????????????????
        // 2. ???????????????30????????????????????????func
        // 3. ????????????????????????????????????
        
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
    
    
    func showAlert_(title: String, message: String, timeToDissapear: Int, on ViewController: UIViewController) {

        
        guard let targetView = ViewController.view else {
            return
        }
        //????????????ViewController.view
//        mytargetView = targetView
        //??????alertView???????????????
        alertView.frame = CGRect(x: view.frame.size.width/2 - 50,
                                 y: view.frame.size.height/2,
                                 width: 100, height: 80)
        alertView.backgroundColor = .black
        alertView.layer.opacity = 0.8
        targetView.addSubview(alertView)
        //??????
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: 100, height: 80))
        //titleLabel.center.y = view.frame.size.height/2
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.backgroundColor = .black
        //??????????????????title????????????
        titleLabel.text = title
        //????????????????????????
        titleLabel.textAlignment = .center
        //?????????titleLabel??????alertView???
        alertView.addSubview(titleLabel)
        
        
        //Setting the NSTimer to close the alert after timeToDissapear seconds.
        _ = Timer.scheduledTimer(timeInterval: Double(timeToDissapear), target: self, selector: #selector(dismissAlert), userInfo: nil, repeats: false)
    }
    
    
    
    //????????????
    @objc func dismissAlert() {
        
        alertView.alpha = 0
    }
    
}
