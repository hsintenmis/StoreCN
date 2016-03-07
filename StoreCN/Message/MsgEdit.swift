//
// Container
//

import UIKit
import Foundation

/**
 * 最新消息編輯
 */
class MsgEdit: UIViewController {
    
    // @IBOutlet
    
    // common property
    private var pubClass: PubClass!
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictData: Dictionary<String, AnyObject> = [:]
    
    
    // 其他參數設定
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}