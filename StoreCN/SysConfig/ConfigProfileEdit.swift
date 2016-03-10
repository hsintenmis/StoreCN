//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class ConfigProfileEdit: UITableViewController, UITextFieldDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    @IBOutlet weak var edName: UITextField!
    @IBOutlet weak var txtTEL: UITextField!
    @IBOutlet weak var txtUsrName: UITextField!
    @IBOutlet weak var txtWechat: UITextField!
    @IBOutlet weak var txtQQ: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtAddr: UITextField!
    
    // common property
    var pubClass: PubClass!
    
    // public property, 上層 parent 設定
    
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
}
