//
//  SSTableViewController.swift
//  Splash
//
//  Created by student on 2021/8/4.
//

import UIKit
import MessageUI
import WebKit
import StoreKit



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



class LGStoreProduct: NSObject {
    
    static let share = LGStoreProduct()
    private override init() { super.init()}
    private var parentVc:UIViewController?
    
    func lg_openStore(currentVc: SettingTableViewController, appID: String)  {
        parentVc = currentVc
        currentVc.present(self.storeVc, animated: true, completion: nil)
        storeVc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appID], completionBlock: {
            (result, error) in
            if result && error == nil {
                print("鏈接加載成功！！！")

            } else {
                print(error as Any)
            }
        })
    }
    
    
    lazy var storeVc: SKStoreProductViewController = {
        let storeVc = SKStoreProductViewController()
        storeVc.delegate = self
        return storeVc
    }()
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

        //setupCellData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                //LGStoreProduct.lg_openStore(<#T##self: LGStoreProduct##LGStoreProduct#>)
            }
        }
    }
    
    //MARK: User Feedback
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        // 設定郵件地址、主題及正文/ 系統版本systemVersion 裝置型號deviceModel
        mailComposeVC.setToRecipients(["<Unpaper.official@gmail.com>"])
        mailComposeVC.setSubject("Unpaper User Feedback")
        mailComposeVC.setMessageBody("\n\n\n\n\nThe following information is provided to the developer, please do not delete!\n---------------------------------\nSystem Version: \(systemVersion)\nDevice Model: \(self.modelName)\nApp Version: \(self.appVersion!)", isHTML: false)
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


}



extension LGStoreProduct: SKStoreProductViewControllerDelegate {
    // Sent if the user requests that the page be dismissed
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        parentVc?.dismiss(animated: true, completion: nil)
    }
}


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
        case "iPod1,1":
            return "iPod Touch 1G"
        case "iPod2,1":
            return "iPod Touch 2G"
        case "iPod3,1":
            return "iPod Touch 3G"
        case "iPod4,1":
            return "iPod Touch 4G"
        case "iPod5,1":
            return "iPod Touch 5G"
        case "iPod7,1":
            return "iPod Touch 6G"
            
        case "iPhone1,1":
            return "iPhone 2G"
        case "iPhone1,2":
            return "iPhone 3G"
        case "iPhone2,1":
            return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4"
        case "iPhone4,1":
            return "iPhone 4s"
            
        case "iPhone5,1":
            return "iPhone 5"
        case "iPhone5,2":
            return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3":
            return "iPhone 5c (GSM)"
        case "iPhone5,4":
            return "iPhone 5c (GSM+CDMA)"
            
        case "iPhone6,1":
            return "iPhone 5s (GSM)"
        case "iPhone6,2":
            return "iPhone 5s (GSM+CDMA)"
            
        case "iPhone7,2":
            return "iPhone 6"
        case "iPhone7,1":
            return "iPhone 6 Plus"
        case "iPhone8,1":
            return "iPhone 6s"
        case "iPhone8,2":
            return "iPhone 6s Plus"
            
        case "iPhone8,4":
            return "iPhone SE"
        /// "国行、日版、港行iPhone 7"
        case "iPhone9,1":
            return "iPhone 7"
        /// "港行、国行iPhone 7 Plus"
        case "iPhone9,2":
            return "iPhone 7 Plus"
        /// "美版、台版iPhone 7"
        case "iPhone9,3":
            return "iPhone 7"
        /// "美版、台版iPhone 7 Plus"
        case "iPhone9,4":
            return "iPhone 7 Plus"
            
        case "iPhone10,1":
            return "iPhone 8"
        case "iPhone10,4":
            return "iPhone 8"
        case "iPhone10,2":
            return "iPhone 8 Plus"
        case "iPhone10,5":
            return "iPhone 8 Plus"
            
        case "iPhone10,3":
            return "iPhone X"
        case "iPhone10,6":
            return "iPhone X"
            
        case "iPhone11,2":
            return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":
            return "iPhone XS Max"
        case "iPhone11,8":
            return "iPhone XR"
            
        case "iPhone12,1":
            return "iPhone 11"
        case "iPhone12,3":
            return "iPhone 11 Pro"
        case "iPhone12,5":
            return "iPhone 11 Pro Max"
            
            
        case "iPhone13,1":
            return "iPhone 12 mini"
        case "iPhone13,2":
            return "iPhone 12"
        case "iPhone13,3":
            return "iPhone 12  Pro"
        case "iPhone13,4":
            return "iPhone 12  Pro Max"
            
        case "iPad1,1":
            return "iPod Touch 1G"
        case "iPad1,2":
            return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPod Touch 2G"
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini 1G"
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":
            return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":
            return "iPad Air 2"
        case "iPad6,3", "iPad6,4":
            return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":
            return "iPad Pro 12.9"
            
        case "AppleTV2,1":
            return "Apple TV 2"
        case "AppleTV3,1", "AppleTV3,2":
            return "Apple TV 3"
        case "AppleTV5,3":
            return "Apple TV 4"
            
        case "i386", "x86_64":
            return "iPhone 11 Pro"
            
        default:
            return "iPhone"
        }
    }

}
