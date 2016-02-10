//
// TableView Cell
//

import Foundation
import UIKit

class ReservListCell: UITableViewCell {
    @IBOutlet weak var labTime: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labStatu: UILabel!
    
    /**
     * 設定 IBOutlet value
     * 'odrs_id': 療程購買訂單編號, 'issale': 是否使用療程
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labTime.text = (ditItem["hh"] as! String) + ":" + (ditItem["min"] as! String)
        labName.text = ditItem["membername"] as? String
        labCourse.text = ditItem["coursename"] as? String
        
        var strStatu = pubClass.getLang("course_nobuy")
        var strColor = pubClass.dictColor["gray"]
        
        if ((ditItem["issale"] as? String) == "Y") {
            strStatu = pubClass.getLang("course_finished")
            strColor = pubClass.dictColor["red"]
        }
        else if ((ditItem["odrs_id"] as! String).characters.count > 0) {
           strStatu = pubClass.getLang("course_alreadybuy")
            strColor = pubClass.dictColor["green"]
        }
        
        labStatu.text = strStatu
        labStatu.textColor = (pubClass.ColorHEX(strColor))
    }
}