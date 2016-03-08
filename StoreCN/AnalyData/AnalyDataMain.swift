//
// with ContainerView, add sub VC to ContainerView
// subViewController 以 storyboard 的 resourceident 實體化產生
//

import UIKit
import Foundation

/**
 * 收入分析主頁面
 */
class AnalyDataMain: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var navybarView: UINavigationBar!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // ContainerView 相關參數
    private var aryChildVC: Array<UIViewController> = []
    weak var currentViewController: UIViewController?
    private let aryVCIdent = ["Today", "Daily", "Monthly"]
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidAppear(animated: Bool) {
        // 實體三個 VC 加入 array
        /*
        for strIdent in aryVCIdent {
            let mVC = self.storyboard?.instantiateViewControllerWithIdentifier("AnalyData" + strIdent)
            aryChildVC.append(mVC!)
        }
        
        self.setContainerPage(0)
        */
        
        self.changVC(0)
    }
    
    /**
     * 設定 contviewPage 的子頁面 View
     */
    private func setContainerPage(position: Int) {
        let newViewController = aryChildVC[position]
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        if (self.currentViewController == nil) {
            self.currentViewController = aryChildVC[0]
        }
        
        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
        self.currentViewController = newViewController
    }
    
    /**
     * ContainerView 新舊頁面轉換
     */
    private func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        
        oldViewController.willMoveToParentViewController(nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView: self.containView!)
        
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animateWithDuration(0.2, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
            completion: { finished in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParentViewController()
                newViewController.didMoveToParentViewController(self)
        })
    }
    
    /**
     * ContainerView 加入頁面
     */
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    private func changVC(position: Int) {
        switch (position) {
        case 0:
            let mVC = storyboard!.instantiateViewControllerWithIdentifier("AnalyDataToday") as! AnalyDataToday

            let mView = mVC.view
            mView.frame.size.height = containView.layer.frame.height
            self.containView.addSubview(mView)
            self.navigationController?.pushViewController(mVC, animated: true)
            break
        default:
            break
        }
    }

    /**
     * act, Segment 子選單，今日/每日/每月 VC 產生加入 containerView
     */
    @IBAction func actSubMenu(sender: UISegmentedControl) {
        //setContainerPage(sender.selectedSegmentIndex)
        
        changVC(sender.selectedSegmentIndex)
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}