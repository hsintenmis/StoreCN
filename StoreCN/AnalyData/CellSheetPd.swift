//
// TableView Cell
//

import Foundation
import UIKit

/**
 * 指定日期收入報表 '商品銷售' Cell
 */
class CellSheetPd: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["id"] as? String
        labPrice.text = ditItem["totprice"] as? String
        labQty.text = ditItem["qty"] as? String
    }
}