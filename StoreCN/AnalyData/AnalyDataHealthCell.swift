//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 健康精靈使用狀況分析 Cell
 */
class AnalyDataHealthCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labTel: UILabel!
    @IBOutlet weak var labMsg: UILabel!
    
    /**
     * 設定 IBOutlet value
     * @tabelFlag : 選擇的 table, 最後使用天數欄位判別用, 'login' or 'test'
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass, tabelFlag: String) {
        
        labName.text = ditItem["membername"] as? String
        labId.text = ditItem["memberid"] as? String
        labTel.text = ditItem["tel"] as? String

        // 設定'最後登入'顯示文字
        var strStat = pubClass.getLang("analydata_usedaynever")
        let days =  (tabelFlag == "login")
            ? Int(ditItem["login_days"] as! String)
            : Int(ditItem["test_days"] as! String)
        
        if (days >= 3650) {
            strStat = pubClass.getLang("analydata_usedaynever")
        }
        else if (days == 0) {
            strStat = pubClass.getLang("analydata_usedaytoday")
        }
        else if (days == 1) {
            strStat = pubClass.getLang("analydata_usedayyest")
        }
        else if (days < 3650) {
            strStat = String(format: pubClass.getLang("format_beforedays"), days!)
        }
        
        labMsg.text = strStat
    }
}