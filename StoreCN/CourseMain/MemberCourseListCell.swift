//
// TableView Cell,
//

import Foundation
import UIKit

/**
* 會員已購買的療程列表 Cell
*/
class MemberCourseListCell: UITableViewCell {
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var labContent: UILabel!
    
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labEddDate: UILabel!
    @IBOutlet weak var labCardType: UILabel!
    @IBOutlet weak var labUseTimes: UILabel!
    @IBOutlet weak var labSugst: UILabel!
    
    private var pubClass = PubClass()
    
    /**
     * 設定 IBOutlet value
     * 'odrs_id': 療程購買訂單編號, 'issale': 是否使用療程
     */
    func initView(ditItem: Dictionary<String, AnyObject>!) {
        // 取得目前指定 Item 的 array data
        labTitle.text = ditItem["pdname"] as? String
        labContent.text = ditItem["pdid"] as? String
        labSdate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 8)
        labEddDate.text = pubClass.formatDateWithStr(ditItem["end_date"] as! String, type: 8)
        labSugst.text = ditItem["card_msg"] as? String
        labUseTimes.text = ditItem["usecount"] as? String
        labSugst.text = ditItem["card_msg"] as? String
        labCardType.text = self.getTypeMsg(ditItem)
    }
    
    /**
     * 取得療程卡資料文字
     */
    private func getTypeMsg(ditItem: Dictionary<String, AnyObject>)->String {
        var strMsg = ""
        let strType = ditItem["card_type"] as! String
        let strTimes = ditItem["card_times"] as! String
        
        if (strType == "M") {
            // 包月文字, 'cardtype' == "M",  card_times = "2",  包月2個月
            strMsg = "\(pubClass.getLang("course_odrstype_M")): \(strTimes)\(pubClass.getLang("course_odrstype_M_unit"))"
        }
        else {
            // 包次文字, 'cardtype' == "T",  card_times = "10", 包次10次
            strMsg = "\(pubClass.getLang("course_odrstype_T")): \(strTimes)\(pubClass.getLang("course_odrstype_T_unit"))"
        }
        
        return (strMsg + ", " + pubClass.getLang("course_fee") + ": \(ditItem["price"]!)")
    }

}