//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 指定日期收入報表 '療程銷售' Cell
 */
class CellSheetCourse: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labData: UILabel!
    @IBOutlet weak var labData1: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["id"] as? String
        labPrice.text = ditItem["totprice"] as? String

        // labData 文字資料產生
        let aryName = ditItem["membername"] as! Array<String>
        let aryPrice = ditItem["price"] as! Array<String>
        let nums = aryName.count
        var strData = "", strData1 = ""
        
        for (var i=0; i < nums; i++) {
            strData += pubClass.getLang("fieldname_membername") + ": " + aryName[i]
            strData1 += pubClass.getLang("fieldname_price") + ": " + aryPrice[i]
            
            if (i < (nums - 1)) {
                strData += "\n"
                strData1 += "\n"
            }
        }
        
        labData.text = strData
        labData1.text = strData1
    }
}