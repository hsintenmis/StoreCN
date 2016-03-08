//
// Container
//

import UIKit
import Foundation

/**
 * 最新消息，社群發佈訊息新增程序，有上傳圖片
 */
class MsgAdd: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var contView: UIView!
    
    // common property
    private var pubClass: PubClass!
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    
    // 其他參數設定
    private var mMsgAddContainer: MsgAddContainer!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MsgAddContainer") {
            mMsgAddContainer = segue.destinationViewController as! MsgAddContainer
            mMsgAddContainer.strToday = strToday
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        print(mMsgAddContainer.getPageData())
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}