//
//  SearchPeopleViewController.swift
//  Splash
//
//  Created by student on 2021/7/31.
//

import UIKit
import JGProgressHUD
import SDWebImage
import SafariServices

class SearchPeopleViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    

    var userDetails: [UserData.Result] = []
    var userDetail: UserData?
    let searcherBar = UISearchBar()
    var hud: JGProgressHUD?
    var page: Int = 1
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addTapGesture()
        searcherBar.delegate = self
        view.addSubview(searcherBar)

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searcherBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.frame.size.width-20, height: 50)
    }
    

    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SearchPeopleTableViewCell else {
            fatalError()
        }
        if let imageString = userDetails[indexPath.row].profileImage?.medium {
            //cell.configure(with: imageString)
            let imageURL = URL(string: imageString)
            cell.userImageView.sd_setImage(with: imageURL, completed: nil)
            cell.userImageView.layer.cornerRadius = 35
        }
        cell.nameLabel.text = userDetails[indexPath.row].name
        if userDetails[indexPath.row].instagramUsername != nil {
            cell.igLabel.text = "@" + userDetails[indexPath.row].instagramUsername!
        } else {
            cell.igLabel.text = "_"
        }
        
        return cell
    }
    
    
    //Go to user Website
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let authorWebsiteString = userDetails[indexPath.row].links?.html, let url = URL(string: authorWebsiteString) {
            print(authorWebsiteString)
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            self.present(safari, animated: true, completion: nil)
        } 
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: SEARCHERBAR
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searcherBar.text {
            hud = JGProgressHUD(style: .dark)
            hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            hud?.show(in: self.view, animated: true)
            userDetails = []
            tableView.reloadData()
            getSearchUserData(query: text, page: page)
        }
    }
    
    
    
    //判斷畫面是否滑到最下面
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > (self.tableView.frame.height) else {return}
        if scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y) <= -10 {
            page += 1
            print("page: \(page)")
            getSearchUserData(query: searcherBar.text!, page: page)
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
                    self.tableView.reloadData()
                }
            }catch{
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
