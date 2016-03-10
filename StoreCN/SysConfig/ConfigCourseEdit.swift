//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class ConfigCourseEdit: UITableViewController, UITextFieldDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    @IBOutlet weak var edHH_Start: UITextField!
    @IBOutlet weak var edHH_End: UITextField!
    @IBOutlet weak var edNums: UITextField!
    
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
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 處理 '星期幾' 點取狀態, section = 1
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section != 1) {
            return
        }
        
        
        
        return
    }
    
}