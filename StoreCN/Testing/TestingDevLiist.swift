//
// Container
//

import UIKit
import Foundation

/**
 * 藍牙設備裝置列表，點取後跳轉對應的藍牙設備檢測頁面
 */
class TestingDevLiist: UIViewController {
    
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