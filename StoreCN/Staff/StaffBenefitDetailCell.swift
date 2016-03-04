//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 指定月份，指定營養師，各個業績列表 Cell
 */
class StaffBenefitDetailCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, currMM: String, PubClass pubClass: PubClass) {
        
        labName.text = ditItem["membername"] as? String
        
        // 日期處理
        var strDate = currMM
        
        if let strTmp = ditItem["sdate"] as? String {
            strDate += "/" + pubClass.subStr(strTmp, strFrom: 6, strEnd: 8)
        }
        if let strTmp = ditItem["dd"] as? String {
            strDate += "/" + strTmp
        }
        labDate.text = strDate
        
        // 單號
        var strId = "--"
        if let strTmp = ditItem["id"] as? String {
            strId = strTmp
        }
        labId.text = strId
        
        // 金額
        var strPrice = "--"
        if let strTmp = ditItem["custprice"] as? String {
            strPrice = strTmp
        }
        labPrice.text = strPrice
        
        // 療程名稱
        var strCourse = ""
        if let strTmp = ditItem["pdname"] as? String {
            strCourse = strTmp
        }
        labCourse.text = strCourse
    }
}