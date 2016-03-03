//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 營養師績效列表 Cell
 */
class StaffBenefitCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labPd: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labCount: UILabel!

    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {

        labName.text = ditItem["usrname"] as? String
        labPd.text = ditItem["tot_pd"] as? String
        labCourse.text = ditItem["tot_course"] as? String
        labCount.text = ditItem["tot_count"] as? String
    }
}