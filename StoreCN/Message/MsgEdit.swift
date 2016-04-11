//
// Container
//

import UIKit
import Foundation

/**
 * 最新消息編輯
 */
class MsgEdit: UIViewController {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    
    // common property
    private var pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private let mImageClass = ImageClass()
    private var mMsgEditCont: MsgEditCont!
    private var isDataSave = false
    
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
        var dictRS = mMsgEditCont.getPageData()
        
        if (dictRS == nil) {
            return
        }
        
        // 重新整理 'dictRS' 內容
        dictRS!["mode"] = "edit"
        
        if let mImg = dictRS!["image"] as? UIImage {
            dictRS!["image"] = mImageClass.ImgToBase64(mImg)
        } else {
            dictRS!["image"] = ""
        }
        
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
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
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
            
            self.isDataSave = true
            self.pubClass.popIsee(self, Msg: strMsg)
        })
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        if (isDataSave == true) {
            self.delegate?.PageNeedReload!(true)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}