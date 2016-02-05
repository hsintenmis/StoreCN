//
// TableView Cell
//

import Foundation
import UIKit

class PubMeadDataSelectCell: UITableViewCell {
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labAvg: UILabel!
    @IBOutlet weak var labAvgH: UILabel!
    @IBOutlet weak var labAvgL: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labDate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: "8s")
        labAvg.text = ditItem["avg"] as? String
        labAvgH.text = ditItem["avgH"] as? String
        labAvgL.text = ditItem["avgL"] as? String
    }
}