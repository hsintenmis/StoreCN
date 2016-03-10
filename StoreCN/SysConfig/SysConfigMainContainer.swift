//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class SysConfigMainContainer: UITableViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
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
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // 根據 cell ident 執行 'performSegueWithIdentifier'
        let strident = tableView.cellForRowAtIndexPath(indexPath)!.reuseIdentifier
        
        if (strident == "cellConfigProfile") {
            self.performSegueWithIdentifier("ConfigProfile", sender: nil)
        }
        
        else if (strident == "cellConfigCourse") {
            self.performSegueWithIdentifier("ConfigCourse", sender: nil)
        }
        
        else if (strident == "cellConfigBTScale") {
            self.performSegueWithIdentifier("ConfigBTScale", sender: nil)
        }

        return
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let strIdent = segue.identifier
        
        return
    }
    
}
