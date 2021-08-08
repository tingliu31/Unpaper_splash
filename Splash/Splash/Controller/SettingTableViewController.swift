//
//  SSTableViewController.swift
//  Splash
//
//  Created by student on 2021/8/4.
//

import UIKit
import MessageUI
import WebKit


public extension UIDevice {

    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }

}



class ClearCacheManage {
    
    class func sizeOfAllCache() -> String {
        //cache目錄
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        //所有文件
        let files = FileManager.default.subpaths(atPath: cachePath!)
        var size: Double = 0
    
        for file in files! {
            let path = (cachePath! as NSString).appending("/\(file)")
            //取出文件屬性
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            //取出文件大小屬性
            for (key, fileSize) in floder {
                //累加文件大小
                if key == FileAttributeKey.size {
                    size += (fileSize as AnyObject).doubleValue
                }
            }
        }
        let cache = size / 1024 / 1024
        print(String(format: "%.1f", cache))
        return String(format: "%.1f", cache)
    }
    
    
    class func clearAllCache() {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let files = FileManager.default.subpaths(atPath: cachePath!)
        for file in files! {
            let path = (cachePath! as NSString).appending("/\(file)")
            if FileManager.default.fileExists(atPath: path) {
                
                do{
                    try FileManager.default.removeItem(atPath: path)
                }catch{
                    
                }
            }
        }
    }
    
    
}



class SettingTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // 獲取裝置名稱
    let deviceName = UIDevice.current.name
    // 獲取系統版本號
    let systemVersion = UIDevice.current.systemVersion
    // 獲取裝置的型號 是iPhone 還是iPad
    let deviceModel = UIDevice.current.model
    // 獲取裝置唯一識別符號
    let deviceUUID = UIDevice.current.identifierForVendor?.uuidString
    //調用
    let modelName = UIDevice.current.modelName
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        setupCellData()
        
        
    }
    
    
    func setupCellData() {
        cacheLabel.text = ClearCacheManage.sizeOfAllCache() + " MB"
        versionLabel.text = "Versions " + appVersion!
        versionLabel.layer.masksToBounds = true
        versionLabel.layer.cornerRadius = 5
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //動畫
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                print("Clear Cache")
                ClearCacheManage.clearAllCache()
                self.cacheLabel.text = ClearCacheManage.sizeOfAllCache() + " MB"
            } else if indexPath.row == 1 {
                print("Feedback")
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeViewController = configuredMailComposeViewController()
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            } else {
                print("rate")
            }
        }
    }
    
    //MARK: User Feedback
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        // 設定郵件地址、主題及正文/ 系統版本systemVersion 裝置型號deviceModel
        mailComposeVC.setToRecipients(["<NUGRU31@gmail.com>"])
        mailComposeVC.setSubject("Splasher User Feedback")
        mailComposeVC.setMessageBody("\n\n\n System Version: \(systemVersion)\n Device Model: \(self.modelName)", isHTML: false)
        return mailComposeVC
    }
        
    
    func showSendMailErrorAlert() {
        //您的裝置尚未設定郵箱,請在“郵件”應用中設定後再嘗試傳送。 無法傳送郵件Sending mail failed.
        let sendMailErrorAlert = UIAlertController(title: "Sending mail failed.", message: "Your device has not set up an email address, please set it in the Mail application and try to send again", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancel.")
        case MFMailComposeResult.sent.rawValue:
            print("Sent successfully!")
        default :
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    

}
