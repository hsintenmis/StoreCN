//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 指定日期收入報表 '會員訂單' Cell
 */
class CellSheetInvoice: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labData: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        labName.text = ditItem["membername"] as? String
        labId.text = ditItem["id"] as? String
        labPrice.text = ditItem["totprice"] as? String
        
        // labData 文字資料產生
        let aryId = ditItem["invoiceid"] as! Array<String>
        let aryPrice = ditItem["invoiceprice"] as! Array<String>
        let nums = aryId.count
        var strData = ""
        
        for (var i=0; i < nums; i++) {
            strData += pubClass.getLang("fieldname_invoiceid") + ": " + aryId[i] + ", " + pubClass.getLang("fieldname_price") + ": " + aryPrice[i]
            
            if (i < (nums - 1)) {
               strData += "\n"
            }
        }
        
        labData.text = strData
    }
}