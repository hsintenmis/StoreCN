//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 庫存列表， cell 內容
 */
class StockCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labPV: UILabel!
    @IBOutlet weak var labQty: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {

        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["pdid"] as? String
        labPV.text = ditItem["pv"] as? String
        labPrice.text = ditItem["price"] as? String
        
        let strQty = ditItem["qty"] as! String
        labQty.text = strQty
        
        // 顏色樣式
        var strColor = pubClass.dictColor["BlueDark"]
        
        if (Int(strQty) <= 5) {
            strColor = pubClass.dictColor["RedDark"]
        }
        
        labQty.textColor = (pubClass.ColorHEX(strColor))
    }
}