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
    
    
    @IBOutlet weak var favCollectionView: UICollectionView!
    
    var favoriteItems = [NSManagedObject]()
    var managedContext: NSManagedObjectContext?
    var hud: JGProgressHUD?
    var cellSizes = [CGSize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tabBarController?.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
        
        
        favCollectionView.register(FavoriteCollectionViewCell.self, forCellWithReuseIdentifier: FavoriteCollectionViewCell.identifier)
        favCollectionView.delegate = self
        favCollectionView.dataSource = self
        favCollectionView.emptyDataSetSource = self
        favCollectionView.emptyDataSetDelegate = self
        setupWaterfallLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //getFavoriteItems()
    }

    
    func getFavoriteItems() {
        favoriteItems = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        
        let getRequest = NSFetchRequest<NSManagedObject>(entityName: "Splash")
        do {
            let unsplash = try managedContext?.fetch(getRequest)
            for data in unsplash! {
                favoriteItems.append(data)
                print(unsplash?.count ?? 0)
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
        waterfallLayout.headerHeight = 50
        waterfallLayout.footerHeight = 20
        waterfallLayout.minimumColumnSpacing = 5
        waterfallLayout.minimumInteritemSpacing = 5
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
    
    //didSelect
    
    
    
    
    
    
}



//MARK: - CollectionViewWaterFallLayoutDelegate
extension FavoriteViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let favorite = favoriteItems[indexPath.row]
        let favoriteWidth = favorite.value(forKey: "width") as! Int
        let favoriteHeight = favorite.value(forKey: "height") as! Int
        cellSizes.append(CGSize(width: favoriteWidth, height: favoriteHeight))
        //print(cellSizes)
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
