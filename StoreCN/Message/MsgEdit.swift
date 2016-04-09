//
// Container
//

import UIKit
import Foundation

/**
 * 最新消息編輯
 */
class MsgEdit: UIViewController {
    
    // @IBOutlet
    
    // common property
    private var pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var mMsgEditCont: MsgEditCont!
    
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
        if (segue.identifier == "MsgEditCont") {
            mMsgEditCont = segue.destinationViewController as! MsgEditCont
            mMsgEditCont.dictData = dictData
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictRS = mMsgEditCont.getPageData()
        
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("sysprompt"), pubClass.getLang("datasendplzconfirmmsg")], withHandlerYes: {}, withHandlerNo: {})
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}