//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 設定 - 店家基本資料
 */
class ConfigProfile: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    var pubClass: PubClass!
    
    // public property, 上層 parent 設定

    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {

    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}