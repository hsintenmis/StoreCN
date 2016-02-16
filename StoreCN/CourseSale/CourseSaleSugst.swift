//
// ViewController
//

import UIKit
import Foundation

/**
 * 療程銷售 新增編輯, 療程建議說明，從 'PubCourseSaleAdEd' 導入
 */
class CourseSaleSugst: UIViewController, SugstChildPageDelegate {
    
    // @IBOutlet
    @IBOutlet weak var contviewPage: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var parentClass: PubCourseSaleAdEd!

    // ContainerView 相關參數
    private var dictChildVC: Dictionary<String, UITableViewController> = [:]
    weak var currentViewController: UIViewController?
    private let aryBtnIdent = ["SugstEpower", "SugstHot", "SugstSun", "SugstEre"]
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        self.initChildVC()
        self.setContainerPage("SugstEpower")
        
        super.viewDidLoad()
        
        // 固定初始參數
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        
        dispatch_async(dispatch_get_main_queue(), {
            

        })
        
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        
    }
    
    /**
    * 初始 ContainerView 需要的 page VC
    */
    private func initChildVC() {
        for strIdent in aryBtnIdent {
            let mVC = self.storyboard?.instantiateViewControllerWithIdentifier(strIdent) as! SugstChildPage
            mVC.delegate = self
            dictChildVC[strIdent] = mVC
        }
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
    
    /**
     * ContainerView 新舊頁面轉換
     */
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        
        oldViewController.willMoveToParentViewController(nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.contviewPage!)
        
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
    * 設定 contviewPage 的子頁面 View
    */
    private func setContainerPage(strIdent: String!) {
        let newViewController = dictChildVC[strIdent]
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        
        if (self.currentViewController == nil) {
            self.currentViewController = dictChildVC[aryBtnIdent[1]]
        }

        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
    }
    
    /**
     * #mark: SugstChildPageDelegate, ContainerPage 子頁面點取 'submit' button
     */
    func SubPageSubmitClick(TxtMsg: String, IdentName: String) {
        print("\(IdentName): \(TxtMsg)")
    }
    
    /**
    * act Segmented, 選單
    */
    @IBAction func swchSugstMenu(sender: UISegmentedControl) {
        setContainerPage(aryBtnIdent[sender.selectedSegmentIndex])
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * act, 點取 '完成' button
     */
    @IBAction func actDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
