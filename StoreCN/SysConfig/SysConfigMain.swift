//
// with ContainerView
//

import UIKit
import Foundation

/**
 * App 系統設定主頁面
 */
class SysConfigMain: UIViewController {
    
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
        //let strIdent = segue.identifier
        
        return
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}