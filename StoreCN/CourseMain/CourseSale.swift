//
// Container
//

import UIKit
import Foundation

/**
 * 療程銷售, container 顯示 '療程編輯' 頁面
 * 本頁面需要的資料由 parent 傳入
 */
class CourseSale: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 療程DB資料, 全部會員資料
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 公用VC, 療程銷售新增/編輯 class
    var mCourseAdEd: CourseAdEd!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
    * 初始與設定本頁面相關參數
    */
    private func initData() {
        // 檢查療程DB資料, 全部會員資料
        aryCourseDB = dictAllData["pd"] as! Array<Dictionary<String, AnyObject>>
        strToday = dictAllData["today"] as! String
        
        if let tmpData = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        }

        if (aryMember.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 療程編輯資料輸入頁面
        if (strIdent == "CourseAdEd") {
            initData()
            mCourseAdEd = segue.destinationViewController as! CourseAdEd
            mCourseAdEd.strToday = strToday
            mCourseAdEd.aryCourseDB = aryCourseDB
            mCourseAdEd.aryMember = aryMember
            mCourseAdEd.strMode = "add"
        }
    }
    
    /**
     * 資料儲存程序
     */
    private func svaeData(dictArg0: Dictionary<String, AnyObject>!) {
        // 產生 http post data, http 連線儲存
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "coursesale"
        dictParm["act"] = "coursesale_senddata"
        
        do {
            let tmpDictData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0 as! Dictionary<String, String>, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: tmpDictData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
        
        // HTTP 開始連線
        var errMsg = self.pubClass.getLang("err_trylatermsg")
        
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            // 回傳通知 parent 資料 reload
            if (dictHTTPSRS["result"] as! Bool == true) {
                errMsg = self.pubClass.getLang("datasavecompleted")
            }
            
            // 跳離本頁
            self.pubClass.popIsee(self, Msg: errMsg, withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
        })
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictData = mCourseAdEd.getPageData()
        if (dictData["rs"] as! Bool != true) {
            pubClass.popIsee(self, Msg: dictData["msg"] as! String)
            return
        }
        
        // confirm 彈出視窗
        let aryMsg = ["", pubClass.getLang("datasendplzconfirmmsg")]
        pubClass.popConfirm(self, aryMsg: aryMsg,
            withHandlerYes:{ self.svaeData(dictData["data"] as! Dictionary<String, AnyObject>) }, withHandlerNo: { return })
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}