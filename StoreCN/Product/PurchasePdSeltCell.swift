//
// TableView Cell
//

import Foundation
import UIKit

/**
* 商品選擇 TableView Cell，從進貨新增頁面轉入
*/
class PurchasePdSeltCell: UITableViewCell {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    @IBOutlet weak var labTot: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {

        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["pdid"] as? String
        
        let intPrice = Int(ditItem["price"] as! String)!
        let intQty = Int(ditItem["qtySel"] as! String)!
        let totPrice = intPrice * intQty
        
        labPrice.text = String(intPrice)
        labQty.text = String(intQty)
        labTot.text = String(totPrice)
    }
}