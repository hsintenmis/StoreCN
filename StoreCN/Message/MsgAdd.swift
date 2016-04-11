//
// Container
//

import UIKit
import Foundation

/**
 * 最新消息，社群發佈訊息新增程序，有上傳圖片
 */
class MsgAdd: UIViewController {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var contView: UIView!
    
    // common property
    private var pubClass: PubClass!
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    
    // 其他參數設定
    private var mMsgAddContainer: MsgAddContainer!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
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
        var dictRS = mMsgAddContainer.getPageData()
        if (dictRS == nil) {
            return
        }
        dictRS!["mode"] = "add"
        
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("sysprompt"), pubClass.getLang("datasendplzconfirmmsg")], withHandlerYes: {self.svaeData(dictRS)}, withHandlerNo: {})
        
        return
    }
    
    /**
     * 資料儲存程序
     * @param dictArg0: http 連線　arg0 參數
     */
    private func svaeData(dictArg0: Dictionary<String, AnyObject>!) {
        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "message"
        dictParm["act"] = "message_senddata"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            //let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            let jsonString = NSString(data: jobjData, encoding: NSASCIIStringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
        
        // HTTP 開始連線
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            let bolRS = dictHTTPSRS["result"] as! Bool
            let strMsg = (bolRS == true) ? self.pubClass.getLang("datasavecompleted") : self.pubClass.getLang("err_trylatermsg")
            
            self.delegate?.PageNeedReload!(true)
            self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        return
    }

    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}