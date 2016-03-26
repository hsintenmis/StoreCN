//
// Container
//

import UIKit
import Foundation

/**
 * 檢測儀主頁面
 */
class Mead: UIViewController {
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}