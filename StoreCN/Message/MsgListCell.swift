//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 訊息發布列表 Cell
 */
class MsgListCell: UITableViewCell {
    @IBOutlet weak var labType: UILabel!
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labTitle: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        let strType = ditItem["type"] as! String
        
        labType.text = pubClass.getLang("message_type_" + strType)
        
        labTitle.text = ditItem["title"] as? String
        labDate.text = pubClass.formatDateWithStr((ditItem["sdate"] as! String), type: "14s")
        
        // 顏色樣式
        var strColor = pubClass.dictColor["gray"]
        if (strType == "pub") {
            strColor = pubClass.dictColor["RedDark"]
        }
        
        labType.textColor = (pubClass.ColorHEX(strColor))
    }
}