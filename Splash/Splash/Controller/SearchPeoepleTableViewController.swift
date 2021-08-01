//
//  SearchPeoepleTableViewController.swift
//  Splash
//
//  Created by student on 2021/7/31.
//

import UIKit
import JGProgressHUD
import SDWebImage

class SearchPeoepleTableViewController: UITableViewController, UISearchBarDelegate {

    
    var userDetails: [UserData.Result] = []
    var userDetail: UserData?
    var hud: JGProgressHUD?
    var page: Int = 1
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var igLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userDetails.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let imageString = self.userDetails[indexPath.row].profileImage?.medium {
            let imageURL = URL(string: imageString)
            cell.imageView?.sd_setImage(with: imageURL, completed: nil)
        }
        
        let name = self.userDetails[indexPath.row].name
        self.nameLabel.text = name
        let ig = self.userDetails[indexPath.row].instagramUsername
        self.igLabel.text = ig
        
        return cell
    }
    
    
    
    //func configure(cell:)
    
    
    
    //MARK: SEARCHERBAR
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            hud = JGProgressHUD(style: .dark)
            hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            hud?.show(in: self.view, animated: true)
            userDetails = []
            tableView.reloadData()
            getSearchUserData(query: text, page: page)
        }
    }
    
    
    
    func getSearchUserData(query: String, page: Int) {
        let urlString = "https://api.unsplash.com/search/users?page=\(page)&per_page=30&query=\(query)&client_id=ujAYBJVDy9u57y3nJsLVr-byAW6bRoCXuLAjnd0OANo"
        
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let userData = data, error == nil else {
                return
            }
            
            do{
                let jsonResult = try JSONDecoder().decode(UserData.self, from: userData)
                for urlResult in jsonResult.results {
                    self.userDetails.append(urlResult)
                }
                print("Got Search jsonResult !!!")
                print("jsonResult count: \(self.userDetails.count)")
                DispatchQueue.main.async {
                    self.hud?.dismiss(animated: true)
                    //table
                }
            }catch{
                print("Search jsonResult Loading error: \(error)")
                return
            }
        }
        task.resume()
    }
    
}
