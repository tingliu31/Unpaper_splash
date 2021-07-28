//
//  SearchViewController.swift
//  Splash
//
//  Created by student on 2021/7/24.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import SDWebImage


class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, UISearchBarDelegate {
    
    
    var searchResults: [Result] = []
    
    private var waterCollectionView: UICollectionView = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.itemRenderDirection = .leftToRight
        layout.columnCount = 2
        let waterCollectionView11 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        waterCollectionView11.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        return waterCollectionView11
    }()
    
    //let waterCollentionView: UICollectionView
    let searcherBar = UISearchBar()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searcherBar.delegate = self
        self.view.addSubview(searcherBar)

        view.addSubview(waterCollectionView)
        waterCollectionView.delegate = self
        waterCollectionView.dataSource = self
        //getSearchData(query: "blue")
        //self.waterCollectionView = waterCollectionView11
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searcherBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        waterCollectionView.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 55, width: view.frame.size.width, height: view.frame.size.height - 60)
        //waterCollectionView.frame = view.bounds //還沒加
        waterCollectionView.backgroundColor = .systemBackground
    }
    
    
    //MARK: SEARCHERBAR
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searcherBar.text {
            searchResults = []
            waterCollectionView.reloadData()
            getSearchData(query: text)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else {
            fatalError()
        }
        let imageURL = (searchResults[indexPath.row].urls?.regular)
        let imageURLString = "\(String(describing: imageURL))"
        cell.configure(with: imageURLString) //下載圖
        print(imageURLString)
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2, height: 200)
    }
    
    
    

    // GetDataFromJson
    func getSearchData(query: String) {
       
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&query=\(query)&client_id=W3yce0SFSW1yllKPYe6gOInwIjp8DLBJGc8UE9Aweb4"
        
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
                    print("jsonResult count: \(self.searchResults.count)")
                }
                print("Got Search jsonResult !!!")
                print(self.searchResults)
                DispatchQueue.main.async {
                    self.waterCollectionView.reloadData()
                }
            } catch {
                print("Search jsonResult Loading error \(error)")
            }
        }
        task.resume()
    }
    
    
}
