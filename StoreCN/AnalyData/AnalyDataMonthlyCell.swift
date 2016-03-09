//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 每月收入, 指定月份資料列表 Cell
 */
class AnalyDataMonthlyCell: UITableViewCell {
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
        
        let strYM = ditItem["yymm"] as! String
        let strDate = pubClass.subStr(strYM, strFrom: 0, strEnd: 4) + "/" + pubClass.subStr(strYM, strFrom: 4, strEnd: 6)
        labDate.text = strDate
    }
}