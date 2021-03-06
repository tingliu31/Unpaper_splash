//
//  Seacher2ViewController.swift
//  Splash
//
//  Created by student on 2021/7/25.
//

import UIKit
import SDWebImage
import DZNEmptyDataSet
import JGProgressHUD

class SeacherImageViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    

    var searchResults: [Result] = []
    private var collectionView: UICollectionView?
    var scrollView: UIScrollView!
    let searcherBar = UISearchBar()
    var hud: JGProgressHUD?
    var page = 1
    //var keyboardDismissTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searcherBar.delegate = self
        view.addSubview(searcherBar)
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        let itemspace: CGFloat = 2
        let columnCount: CGFloat = 2
        layout.minimumLineSpacing = itemspace
        layout.minimumInteritemSpacing = itemspace
        layout.itemSize = CGSize(width: (view.frame.size.width-itemspace)*(columnCount-1)/columnCount, height: (view.frame.size.width-itemspace)*(columnCount-1)/columnCount )
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(SearchImageCollectionViewCell.self, forCellWithReuseIdentifier: SearchImageCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        self.collectionView = collectionView
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searcherBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 65, width: view.frame.size.width, height: view.frame.size.height - 65)
        //collectionView?.frame = view.bounds //??????????????????searcherBar???
        
    }
    
    
    //MARK: SEARCHERBAR
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searcherBar.text {
            hud = JGProgressHUD(style: .dark)
            hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            hud?.show(in: self.view, animated: true)
            searchResults = []
            collectionView?.reloadData()
            
            getSearchData(query: text ,page: page)
        }
    }

    
    // MARK: CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchImageCollectionViewCell.identifier, for: indexPath) as? SearchImageCollectionViewCell else {
            fatalError()
        }
        if let imageURL = searchResults[indexPath.row].urls?.regular {
        cell.configure(with: imageURL) //?????????
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let DetailVC = self.storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailViewController {
            DetailVC.photoDetails2 = searchResults[indexPath.row]
            DetailVC.modalPresentationStyle = .fullScreen
            present(DetailVC, animated: true, completion: nil)
            //self.navigationController?.pushViewController(DetailVC, animated: true)
            
        }
    }
    
    
    //???????????????????????? DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            guard let row = collectionView?.indexPathsForSelectedItems?.first?.row else {return}
            destination.photoDetails2? = searchResults[row]
                //photoListData[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > (self.collectionView?.frame.height)! else {return}
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            page += 1
            print("page: \(page)")
            getSearchData(query: searcherBar.text!, page: page)
        }
    }
    
    
    
  
    
    
    // GetDataFromJson
    func getSearchData(query: String, page: Int) {
       
        let urlString = "https://api.unsplash.com/search/photos?page=\(page)&per_page=30&query=\(query)&client_id=ujAYBJVDy9u57y3nJsLVr-byAW6bRoCXuLAjnd0OANo"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(SearchData.self, from: data)
                for urlResults in jsonResult.results {
                    self.searchResults.append(urlResults)
                }
                print("Got Search jsonResult !!!")
                print("jsonResult count: \(self.searchResults.count)")
                DispatchQueue.main.async {
                    self.hud?.dismiss(animated: true)
                    self.collectionView?.reloadData()
                }
            } catch {
                print("Search jsonResult Loading error: \(error)")
                return
            }
        }
        task.resume()
    }
    
    
    
    func addTapGesture(){
            let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(tap)
        }
    @objc private func hideKeyboard(){
            self.view.endEditing(true)
        }
    
}




//MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
extension SeacherImageViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView?) -> NSAttributedString? {
        let text = "Tap the search bar to search"
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}
