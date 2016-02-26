//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 進貨退回列表 cell 內容
 */
class PurchaseReturnListCell: UITableViewCell {
    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labTotPrice: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        labDate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 14)
        labPrice.text = ditItem["price"] as? String
        labTotPrice.text = ditItem["custprice"] as? String
    }
}