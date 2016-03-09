//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 每日收入, 指定月份資料列表 Cell
 */
class AnalyDataDailyCell: UITableViewCell {
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labPd: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        labPd.text = ditItem["totcourse"] as? String
        labCourse.text = ditItem["totpd"] as? String
        labPrice.text = ditItem["totodrs"] as? String
        labDate.text = ditItem["date"] as? String
    }
}