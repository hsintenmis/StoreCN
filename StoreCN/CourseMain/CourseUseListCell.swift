//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 療程使用記錄列表 Table Cell
 */
class CourseUseListCell: UITableViewCell {
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labMsg: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labName.text = ditItem["staffname"] as? String
        labSdate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 14)
        labMsg.text = ditItem["memo"] as? String
        
    }
}