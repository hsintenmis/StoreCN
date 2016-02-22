//
// TableView Cell
//

import Foundation
import UIKit

/**
*  會員購貨資料 Table Cell 設定
*/
class PubMemberPurchaseSelectCell: UITableViewCell {
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labReturnPriceCust: UILabel!
    
    @IBOutlet weak var strReturnPrice: UILabel!
    
    /**
     * 設定 IBOutlet value
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, PubClass pubClass: PubClass) {
        
        labSdate.text = pubClass.formatDateWithStr(ditItem["sdate"] as! String, type: 14)
        labId.text = ditItem["id"] as? String
        labPrice.text = ditItem["price"] as? String
        labCustPrice.text = ditItem["custprice"] as? String
        
        let returnPrice = ditItem["returnpricecust"] as? String
        if ( Int(returnPrice!) > 0) {
            labReturnPriceCust.alpha = 1
            strReturnPrice.alpha = 1
            labReturnPriceCust.text = returnPrice
        } else {
            labReturnPriceCust.alpha = 0
            strReturnPrice.alpha = 0
        }
    }
}