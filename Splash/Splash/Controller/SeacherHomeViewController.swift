//
//  SeacherHomeViewController.swift
//  Splash
//
//  Created by student on 2021/7/31.
//

import UIKit

class SeacherHomeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
       
    }
    

    @IBAction func changePageSegment(_ sender: UISegmentedControl) {
        let x = CGFloat(sender.selectedSegmentIndex) * scrollView.bounds.width
                let offset = CGPoint(x: x, y: 0)
                scrollView.setContentOffset(offset, animated: true)
        
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageSegment.selectedSegmentIndex = index
        }

}
