//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 員工資料 新增/編輯
 */
class StaffAdEd: UIViewController {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    private var pubClass = PubClass()
    
    // public, parent 設定
    var strMode: String!
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mStaffAdEdContainer: StaffAdEdContainer!
    private var bolDataSave = false  // 本頁面資料是否有儲存

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
        mStaffAdEdContainer = segue.destinationViewController as! StaffAdEdContainer
        mStaffAdEdContainer.strMode = strMode
        mStaffAdEdContainer.dictMember = dictMember
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        var dictRS = mStaffAdEdContainer.getPageData()
        
        if (dictRS == nil) {
            return
        }
        
        dictRS!["mode"] = strMode
        
        if (strMode == "edit") {
            dictRS!["id"] = dictMember["id"] as! String
        }
        
        // 確認視窗
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
        dictParm["page"] = "staff"
        dictParm["act"] = "staff_senddata"
        
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
            
            // 儲存成功，通知 parent 資料變動
            if (bolRS == true) {
                // 編輯模式
                if (self.strMode == "edit") {
                    self.pubClass.popIsee(self, Msg: strMsg)
                    self.bolDataSave = true
                    return
                }
                    // 新增模式直接跳離
                else if (self.strMode == "add") {
                    self.delegate?.PageNeedReload!(true)
                    self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                    return
                }
            }
            
            self.pubClass.popIsee(self, Msg: strMsg)
        })
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        if (bolDataSave == true) {
            self.delegate?.PageNeedReload!(true)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}