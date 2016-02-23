//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 庫存列表， cell 內容
 */
class StockHistoryCell: UITableViewCell {
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labType: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labTotPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    @IBOutlet weak var labInfo: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        // field value 設定
        labDate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: "14s")
        
        let qty = Int(ditItem["qty"] as! String)!
        let price = Int(ditItem["price"] as! String)!
        let tot = qty * price
        
        labPrice.text = String(price)
        labQty.text = String(qty)
        labTotPrice.text = String(tot)
        
        // 顯示會員名稱/美利銷貨單號
        let strType = ditItem["odrstype"] as! String
        var strInfo = ""
        
        if (strType == "I" || strType == "RI") {
            strInfo = "会员名称: \(ditItem["membername"] as! String)"
        } else {
            strInfo = "美利销货单号: \(ditItem["hte_id"] as! String)"
        }
        
        labInfo.text = strInfo
        
        // 出貨型態對應數量文字顏色, 名稱
        let mapTypeColor = ["I":"RedDark", "P":"BlueDark", "RI":"BlueDark", "RP":"RedDark"]
        let mapTypeName = ["I":"销货", "P":"进货", "RI":"会员退货", "RP":"进货退回"]
        let mColor = pubClass.ColorHEX(pubClass.dictColor[mapTypeColor[strType]!])
        
        labType.text = mapTypeName[strType]
        labType.textColor = mColor
        labQty.textColor = mColor
    }
    
}