//
//  ImageOperation.swift
//  Splash
//
//  Created by student on 2021/7/24.
//

import Foundation
import  UIKit

class ImageOperation: Operation {
    
    var imageURL: URL
    var indexPath: IndexPath
    var tableView: UITableView
    var textLabel: String
    
    init(url: URL, String: String, indexPath: IndexPath, tableView: UITableView) {
        self.imageURL = url
        self.indexPath = indexPath
        self.tableView = tableView
        self.textLabel = String
        super.init()
    }
    
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        //預設情況會在背景執行
        //根據url下載圖檔
        //根據位置indexPath 更新回tableView's cell
        if let imageData = try? Data(contentsOf: imageURL) {
            let image = UIImage(data: imageData)
            //let name = self.photoListData[indexPath.row].user?.name
            DispatchQueue.main.async {
                //如果下載完，當時的位置還在畫面上，才會更新那個cell1，如果不在畫面上就等於白下載了
                if let cell1 = self.tableView.cellForRow(at: self.indexPath){
                    cell1.imageView?.image = image
                    cell1.setNeedsLayout()
                }
            }
        }
    }
}
