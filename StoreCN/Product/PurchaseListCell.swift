//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 進貨列表， cell 內容
 */
class PurchaseListCell: UITableViewCell {
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labReturn: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labTotPrice: UILabel!

    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labDate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 14)
        labPrice.text = ditItem["price"] as? String
        labTotPrice.text = ditItem["custprice"] as? String
        
        // 美利單號
        var strIdMsg = ditItem["hte_id"] as! String
        if (strIdMsg != "") {
            strIdMsg = String(format: pubClass.getLang("FMT_MTInvoId"), strIdMsg)
        }
        labId.text = strIdMsg
        
        // 退貨金額訊息
        var strReturnMsg = ""
        if let _ = ditItem["return"] as? Array<AnyObject> {
            strReturnMsg = String(format: pubClass.getLang("FMT_returnmsg"), ditItem["returnprice"] as! String, ditItem["returnpricecust"] as! String)
        }
        labReturn.text = strReturnMsg
    }
}