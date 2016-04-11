//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 今日提醒, 庫存列表， cell 內容
 */
class RemindStockCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labQty: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["pdid"] as? String
        
        let strQty = ditItem["stocknums"] as! String
        labQty.text = strQty
        
        // 顏色樣式
        var strColor = pubClass.dictColor["BlueDark"]
        
        if (Int(strQty) <= 5) {
            strColor = pubClass.dictColor["RedDark"]
        }
        
        labQty.textColor = (pubClass.ColorHEX(strColor))
    }
}