//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 今日提醒, 會員購買療程列表 Table Cell
 */
class RemindCourseCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labCount: UILabel!
    @IBOutlet weak var LabEdate: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labInvo: UILabel!
    @IBOutlet weak var labExpire: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labName.text = ditItem["membername"] as? String
        labInvo.text = ditItem["invo_id"] as? String
        labCourse.text = ditItem["pdname"] as? String
        //labCount.text = ditItem["usecount"] as? String
        
        LabEdate.text = pubClass.formatDateWithStr(ditItem["end_date"] as! String, type: "8s")
        labSdate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: "8s")
    }
}