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
    func initView(ditItem: Dictionary<String, String>!, PubClass pubClass: PubClass) {
        labDate.text = pubClass.formatDateWithStr(ditItem["sdate"], type: "8s")
        labAvg.text = ditItem["avg"]
        labAvgH.text = ditItem["avgH"]
        labAvgL.text = ditItem["avgL"]
    }
}