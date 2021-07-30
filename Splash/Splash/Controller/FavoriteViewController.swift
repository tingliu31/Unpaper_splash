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
                //dictionarySelectedIndexPath.removeAll()
                
                selectBarBtn.title = "Selet"
                navigationItem.leftBarButtonItem = nil
                favCollectionView.allowsMultipleSelection = false
            case .select:
                selectBarBtn.title = "Cancel"
                navigationItem.leftBarButtonItem = deleteBarBtn
                favCollectionView.allowsMultipleSelection = true
            }
        }
    }
    
    var selectedItems = [NSManagedObject]()
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    var favoriteItems = [NSManagedObject]()
    var managedContext: NSManagedObjectContext?
    var hud: JGProgressHUD?
    var cellSizes = [CGSize]()
    
    
    //宣告selestBtn & deleteBtn
    @IBOutlet weak var favCollectionView: UICollectionView!
    @IBOutlet weak var selectBarBtn: UIBarButtonItem!
    @IBOutlet weak var deleteBarBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        var deletNeededIndexPaths: [IndexPath] = []
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                deletNeededIndexPaths.append(key)
            }
        }
        for i in deletNeededIndexPaths {
            favoriteItems.remove(at: i.row)
        }
        for x in selectedItems {
            context.delete(x)
        }
        do {
            try context.save()
            DispatchQueue.main.async {
                self.favCollectionView.deleteItems(at: deletNeededIndexPaths)
                self.favCollectionView.reloadData()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        // 要刪除被選中的物件
        //let
       //self.delete(indexPath: )
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//        for x in item {
//            context.delete(x)
//        }
//        do {
//            try context.save()
//            DispatchQueue.main.async {
//                self.favCollectionView.reloadData()
//            }
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
        //dictionarySelectedIndexPath.removeAll()
    }
    
    
    
    func getFavoriteItems() {
        favoriteItems = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Splash")
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
    
    
    func delete(indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        context.delete(favoriteItems[indexPath.row] as NSManagedObject)
        favoriteItems.remove(at: indexPath.row)
        
        do {
            try context.save()
            self.favCollectionView.deleteItems(at: [indexPath])
             //Loaf("Your image successfully deleted!", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
            DispatchQueue.main.async {
                self.favCollectionView.reloadData()
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
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
            favCollectionView.deselectItem(at: indexPath, animated: true)
            let didSelectItem = favoriteItems[indexPath.row]
            performSegue(withIdentifier: "favToDetailVCSegue", sender: didSelectItem)
            
            guard let url = URL(string: didSelectItem.value(forKey: "imageURL") as! String) else {return}
            //這裡是選中可進下一頁
        //被選中的物件
        case .select:
            dictionarySelectedIndexPath[indexPath] = true //可選狀態
            let i = favoriteItems[indexPath.row]
            selectedItems.append(i)
            print(i)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //是select中，
        if mMode == .select {
            //選中的無法再選
            dictionarySelectedIndexPath[indexPath] = false
        }
    }
    
    
    //傳送資料到下一頁 DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            guard let row = favCollectionView?.indexPathsForSelectedItems?.first?.row else {return}
            
            //guard let url = URL(string: favorite.value(forKey: "imageURL") as! String) else { return }
            //destination.photoDetails2? = searchResults[row]
                //photoListData[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    
}



//MARK: - CollectionViewWaterFallLayoutDelegate
extension FavoriteViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let favorite = favoriteItems[indexPath.row]
        let favoriteWidth = favorite.value(forKey: "width") as? Int ?? 800
        let favoriteHeight = favorite.value(forKey: "height") as! Int
        cellSizes.append(CGSize(width: favoriteWidth, height: favoriteHeight))
        print(cellSizes)
        return cellSizes[indexPath.item]
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
