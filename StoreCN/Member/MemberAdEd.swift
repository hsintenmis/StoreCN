//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class MemberAdEd: UIViewController {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var navyTitle: UINavigationItem!
    
    
    // common property
    var pubClass: PubClass!
    
    // public property, 上層 parent 設定
    var strToday: String!
    var strMode = "add"
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mMemberAdEdContainer: MemberAdEdContainer!
    private var bolDataSave = false  // 編修模式是否存擋
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        if (strMode == "add") {
            navyTitle.title = pubClass.getLang("member_add")
        }
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "containerMemberAdEd") {
            mMemberAdEdContainer = segue.destinationViewController as! MemberAdEdContainer
            mMemberAdEdContainer.strToday = strToday
            mMemberAdEdContainer.strMode = strMode
            mMemberAdEdContainer.dictMember = dictMember
            
            return
        }
        
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
        dictParm["page"] = "member"
        dictParm["act"] = "member_senddata"
        
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
            
            // 儲存成功，通知 parent (parent 為 'MemberMain') 資料變動
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
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        var dictRS = mMemberAdEdContainer.getPageData()
        
        if (dictRS == nil) {
            return
        }
        
        dictRS!["mode"] = strMode

        if (strMode == "edit") {
            dictRS!["id"] = dictMember["memberid"] as! String
        }
        
        svaeData(dictRS)
    }
    
    /**
     * act, 編輯模式點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        if (bolDataSave == true) {
            self.delegate?.PageNeedReload!(true, arg0: "memberedit")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}