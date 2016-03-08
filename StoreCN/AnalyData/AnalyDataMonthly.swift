//
// TableView
//

import UIKit
import Foundation

/**
 * 每月銷售列表, 商品/療程 總收入
 */
class AnalyDataMonthly: UIViewController {
    
    // @IBOutlet
    
    // common property
    private var pubClass: PubClass!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
}