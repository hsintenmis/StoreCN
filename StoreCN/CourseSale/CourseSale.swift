//
// Container
//

import UIKit
import Foundation

/**
 *  主選單服務管理 - 療程銷售
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
    var mPubCourseSaleAdEd: PubCourseSaleAdEd!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // !! container 直接加入 ViewControler, 切換其他 storyboard
        let storyboard = UIStoryboard(name: "CourseSaleAdEd", bundle: nil)
        mPubCourseSaleAdEd = storyboard.instantiateViewControllerWithIdentifier("PubCourseSaleAdEd") as! PubCourseSaleAdEd
        
        mPubCourseSaleAdEd.strToday = strToday
        mPubCourseSaleAdEd.aryCourseDB = aryCourseDB
        mPubCourseSaleAdEd.aryMember = aryMember
        
        let mView = mPubCourseSaleAdEd.view
        mView.frame.size.height = contviewTable.layer.frame.height
        mView.frame.size.width = contviewTable.layer.frame.width
        
        contviewTable.addSubview(mView)
    }
    
    /**
     * 資料儲存程序
     */
    private func procSave() {
        
        let dictData = mPubCourseSaleAdEd.saveData()
        
        if (dictData["rs"] as! Bool != true) {
            pubClass.popIsee(self, Msg: dictData["msg"] as! String)
            return
        }
        
        // 產生 http post data, http 連線儲存
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "coursesale"
        dictParm["act"] = "coursesale_senddata"
        
        do {
            let tmpDictData = try
                NSJSONSerialization.dataWithJSONObject(dictData["data"] as! Dictionary<String, String>, options: NSJSONWritingOptions(rawValue: 0))
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
        // confirm 彈出視窗
        let aryMsg = ["", pubClass.getLang("datasendplzconfirmmsg")]
        pubClass.popConfirm(self, aryMsg: aryMsg,
            withHandlerYes:{ self.procSave() }, withHandlerNo: { return })
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}