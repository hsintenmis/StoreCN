//
// UITextField 欄位 disable copy / paste / select 功能
//

import Foundation
import UIKit  // don't forget this

class CustomUITextField: UITextField {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        
        return false
        
        /*
        if (action == "paste:" || action == "copy:" || action == "select:") {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
        */
    }
}