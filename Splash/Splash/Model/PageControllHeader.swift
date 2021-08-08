//
//  PageControllHeader.swift
//  Splash
//
//  Created by student on 2021/8/7.
//

import UIKit


protocol PageControlHeaderDelegate: NSObjectProtocol {
    func pageControlBtnClick(index: Int)
}


/// 屏幕宽度
public let screenWidth: CGFloat = UIScreen.main.bounds.size.width
/// 屏幕高度
public let screenHeight: CGFloat = UIScreen.main.bounds.size.height
/// StatusBar和NavigationBar的高度和
public let statusBarAndNavigationBarHeight: CGFloat = iPhoneX ? 88.0 : 64.0

/// 是否是iPhoneX（包含XR XS XS MAX）
public var iPhoneX: Bool {
    if screenHeight == 812 || screenHeight == 896{
        return true
    }else{
        return false
    }
}




class ZLPageControlHeader: UIView {

    lazy var lineV: UIView = {
        let lineV = UIView(frame: .zero)
        lineV.backgroundColor = UIColor.black
        return lineV
    }()
    
    var btnArray: NSMutableArray = NSMutableArray()
    var btnWidth: CGFloat = 50
    var defaultSpace: CGFloat = 30  //距离父视图左右两边的间距
    var lineHeight: CGFloat = 2
    var selectIndex: Int = 0//这里索引换成DepositStatus, 默认 0
    weak var delegate: PageControlHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func configUIWithTitleArray(titleArray: [String]) {
        if titleArray.count  < 1 { return }
        let space: CGFloat = (screenWidth - defaultSpace * 2.0 - btnWidth * CGFloat(titleArray.count))/(CGFloat(titleArray.count) - 1.0)
        for i in 0..<titleArray.count {
            let btn = UIButton(type: .custom)
            btn.setTitle(titleArray[i], for: .normal)
            btn.setTitleColor(UIColor.lightGray, for: .normal)
            btn.setTitleColor(UIColor.black, for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.tag = 10 + i
            btn.frame = CGRect(x: defaultSpace + CGFloat(i) * (btnWidth + space) , y: 0, width: btnWidth, height: self.frame.size.height - lineHeight)
            btn.addTarget(self, action: #selector(controlButtonClick(sender:)), for: .touchUpInside)
            self.addSubview(btn)
            if i == selectIndex {
                btn.isSelected = true
                lineV.frame = CGRect(x: btn.frame.origin.x - lineV.frame.size.width/2.0, y: btn.frame.size.height, width: 16, height: lineHeight)
                lineV.center.x = btn.center.x
                self.addSubview(lineV)
            } else {
                btn.isSelected = false
            }
            btnArray.add(btn)
        }
    }
    
    @objc func controlButtonClick(sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            for i in 0..<self.btnArray.count {
                if let btn = self.btnArray[i] as? UIButton {
                    if btn.isSelected {
                        btn.isSelected = false
                    }
                }
            }
            sender.isSelected = true
            //            self.lineV.frame = CGRect(x: sender.centerX - self.lineV.width/2.0, y: sender.bottom, width: 16, height: 2)
            self.lineV.center.x = sender.center.x
        }
        self.delegate?.pageControlBtnClick(index: sender.tag - 10)
    }
    
}
