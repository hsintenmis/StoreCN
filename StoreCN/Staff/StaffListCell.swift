//
// TableView Cell
//

import Foundation
import UIKit

/**
* 營養師列表 Cell
*/
class StaffListCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labGender: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labBirth: UILabel!
    @IBOutlet weak var labLesson: UILabel!
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        let currYY = Int(pubClass.subStr(pubClass.getDevToday(), strFrom: 0, strEnd: 4))
        var strAge = String(currYY! - Int(pubClass.subStr(ditItem["birth"] as! String, strFrom: 0, strEnd: 4))!)
        
        let strGender = pubClass.getLang("gender_" + (ditItem["gender"] as! String))
        strAge += " " + pubClass.getLang("name_age")
        let strId = ditItem["id"] as! String
        
        labId.text = strId
        labName.text = ditItem["usrname"] as? String
        labGender.text = strGender + " " + strAge
        labTel.text = ditItem["tel"] as? String
        labBirth.text = pubClass.formatDateWithStr(ditItem["birth"] as! String, type: "8s")
        
        // 檢查課程資料
        var strLesson = ""
        
        if let tmpAry = ditItem["lesson"] as? Array<Dictionary<String, String>> {
            
            for i in (0..<tmpAry.count) {
                let dictLesson = tmpAry[i]
                strLesson += "[" +
                    pubClass.formatDateWithStr(dictLesson["sdate"], type: "8s") + " ] " + dictLesson["description"]!
                
                if (i < tmpAry.count - 1) {
                    strLesson += "\n";
                }
            }
        }
        
        labLesson.text = strLesson
        
    }
}