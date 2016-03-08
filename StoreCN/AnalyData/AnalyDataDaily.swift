//
// CollectionView, TableView
//

import UIKit
import Foundation

/**
 * 選擇月份，列出該月份每天的資料列表
 */
class AnalyDataDaily: UIViewController {
    
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