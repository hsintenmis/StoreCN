//
// TableView Cell
//

import Foundation
import UIKit

class CourseListCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labCount: UILabel!
    @IBOutlet weak var LabEdate: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labInvo: UILabel!
    
    /**
    * 設定 IBOutlet value
    */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labName.text = ditItem["membername"] as? String
        labInvo.text = ditItem["invo_id"] as? String
        labCount.text = ditItem["usecount"] as? String
        labCourse.text = ditItem["pdname"] as? String
        
        LabEdate.text = pubClass.formatDateWithStr(ditItem["end_date"] as! String, type: "8s")
        labSdate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: "8s")
    }
}