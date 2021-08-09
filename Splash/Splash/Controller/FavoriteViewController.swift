//
//  LoginViewController.swift
//  Splash
//
//  Created by student on 2021/7/23.
//

import UIKit
import CoreData
import JGProgressHUD
import CollectionViewWaterfallLayout
import DZNEmptyDataSet

class FavoriteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    enum Mode {
        case view
        case select
    }
    
    var mMode: Mode = .view {
        didSet{
            switch mMode {
            case .view:
                for (key, value) in dictionarySelectedIndexPath {
                    if value {
                        favCollectionView.deselectItem(at: key, animated: true)
                    }
                }
                dictionarySelectedIndexPath.removeAll()
                
                selectBarBtn.title = "Select"
                selectBarBtn.tintColor = .black
                navigationItem.leftBarButtonItem = nil
                favCollectionView.allowsMultipleSelection = false
            case .select:
                selectBarBtn.title = "Cancel"
                navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didDeleteButtonClicked(_:)))
                navigationItem.leftBarButtonItem?.tintColor = .black
                favCollectionView.allowsMultipleSelection = true
            }
        }
    }
    
    
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    var favoriteItems = [Splash]()
    var managedContext: NSManagedObjectContext?
    var hud: JGProgressHUD?
    var cellSizes = [CGSize]()
    
    
    //宣告selestBtn & deleteBtn
    @IBOutlet weak var favCollectionView: UICollectionView!
    @IBOutlet weak var selectBarBtn: UIBarButtonItem!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
        selectBarBtn.tintColor = .black
        favCollectionView.delegate = self
        favCollectionView.dataSource = self
        favCollectionView.emptyDataSetSource = self
        favCollectionView.emptyDataSetDelegate = self
        setupWaterfallLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavoriteItems()
    }

    
    @IBAction func didSelectButtonClicked(_ sender: Any) {
        
        mMode = mMode == .view ? .select : .view
    }
    
    
    @IBAction func didDeleteButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        //刪除物件的位置
        //key是IndexPath
        var deletNeededIndexPaths: [IndexPath] = []
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                deletNeededIndexPaths.append(key)
            }
        }
        //刪除 收藏畫面的物件---------------------
        //問題： i.row是指畫面上的第幾筆, 要刪除的是被選中的那筆資料
        for i in deletNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
            
            
            context.delete(favoriteItems[i.item] as NSManagedObject)
            favoriteItems.remove(at: i.item)
        }
        self.favCollectionView.deleteItems(at: deletNeededIndexPaths)
        dictionarySelectedIndexPath.removeAll()

        do {
            try context.save()

            DispatchQueue.main.async {
                self.favCollectionView.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    func getFavoriteItems() {
        favoriteItems = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Splash>(entityName: "Splash")
        do {
            let unsplash = try managedContext?.fetch(fetchRequest)
            for data in unsplash! {
                favoriteItems.append(data)
                DispatchQueue.main.async {
                    self.hud?.dismiss(animated: true)
                    self.favCollectionView.reloadData()
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    
    func setupWaterfallLayout() {
        let waterfallLayout = CollectionViewWaterfallLayout()
        waterfallLayout.columnCount = 2
        waterfallLayout.headerHeight = 20
        waterfallLayout.footerHeight = 20
        waterfallLayout.minimumColumnSpacing = 10
        waterfallLayout.minimumInteritemSpacing = 10
        favCollectionView.collectionViewLayout = waterfallLayout
    }
    
    
    
    //MARK: -CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favoriteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
        let favoriteObject = favoriteItems[indexPath.row]
        favoriteCell.configureCell(favorite: favoriteObject)
        return favoriteCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mMode {
        case .view:
            //這裡是選中可進下一頁
            favCollectionView.deselectItem(at: indexPath, animated: true)
            if let DetailVC = self.storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailViewController {
                DetailVC.photoDetails3 = favoriteItems[indexPath.row]
                DetailVC.modalPresentationStyle = .fullScreen
                present(DetailVC, animated: true, completion: nil)
                //self.navigationController?.pushViewController(DetailVC, animated: true)
                
            }
            print("id: \(favoriteItems[indexPath.row].value(forKey: "id") as? String ?? "")")
            
        //被選中的物件
        case .select:
            dictionarySelectedIndexPath[indexPath] = true //可選狀態

        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //是select中，
        if mMode == .select {
            //選中的無法再選
            dictionarySelectedIndexPath[indexPath] = false
        }
    }
    
    
    
}



//MARK: - CollectionViewWaterFallLayoutDelegate
extension FavoriteViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let favorite = favoriteItems[indexPath.row]
        let size = CGSize(width: Int(favorite.width), height: Int(favorite.height))
        //print("\(indexPath.row) = \(size)")
        return size
    }
    
}


//MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
extension FavoriteViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView?) -> NSAttributedString? {
        let text = "Add some images to your favorite to see the list!"
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}
