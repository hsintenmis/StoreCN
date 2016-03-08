//
// ViewController, contviewPage 子頁產生加入 containerview 轉換
//

import UIKit
import Foundation

/**
 * 療程銷售 新增編輯, 療程建議說明，從 'PubCourseSaleAdEd' 導入
 */
class CourseSaleSugst: UIViewController, SugstChildPageDelegate {
    
    // @IBOutlet
    @IBOutlet weak var contviewPage: UIView!
    @IBOutlet weak var txtSugst: UITextView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 其他參數設定
    var parentClass: PubCourseSaleAdEd!
    var dictSugstTxt: Dictionary<String, String> = [:]

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
        for strKey in aryBtnIdent {
            dictSugstTxt[strKey] = ""
        }
        
        // textView 外觀樣式
        txtSugst.layer.cornerRadius = 5
        txtSugst.layer.borderWidth = 1
        txtSugst.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtSugst.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
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
    private func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        
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
        // 取得 page 傳回文字重新覆蓋 array, 重新顯示 TextView 文字
        dictSugstTxt[IdentName] = TxtMsg
        var strMsg = ""
        
        for strKey in aryBtnIdent {
            if (dictSugstTxt[strKey]?.characters.count > 0 ) {
                strMsg += dictSugstTxt[strKey]! + "\n\n"
            }
        }
        
        txtSugst.text = strMsg
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
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    /**
     * act, 點取 '完成' button
     */
    @IBAction func actDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {self.parentClass.setCourseSugstTxt(self.txtSugst.text)})
    }

}
