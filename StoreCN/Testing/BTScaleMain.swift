//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * 體脂計頁面, Container
 */
class BTScaleMain: UIViewController {
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 藍牙體脂計量測子頁面
    private var mBTScaleMainCont: BTScaleMainCont!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // Container 轉入體脂計主頁面
        if (strIdent == "BTScaleMainCont") {
            mBTScaleMainCont = segue.destinationViewController as! BTScaleMainCont
            mBTScaleMainCont.strToday = self.strToday
            mBTScaleMainCont.aryMember = self.aryMember
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        // 檢查 child BT 是否連線中
        mBTScaleMainCont.dicConnBT()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}