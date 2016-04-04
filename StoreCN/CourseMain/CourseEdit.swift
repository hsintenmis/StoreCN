//
// Container
//

import UIKit
import Foundation

/**
 * 療程編輯, Container 跳轉至 'CourseAdEd'
 */
class CourseEdit: UIViewController {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var contviewTable: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictSaleData: Dictionary<String, AnyObject> = [:]  // 欄位資料 dict data
    var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var strToday = ""
    
    // 公用VC, 療程銷售新增/編輯 class
    var mCourseAdEd: CourseAdEd!
    
    // 其他參數
    private var bolDataChange = false  // 本頁面資料是否有儲存
    
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
        
        // 療程編輯資料輸入頁面
        if (strIdent == "CourseAdEd") {
            mCourseAdEd = segue.destinationViewController as! CourseAdEd
            mCourseAdEd.dictSaleData = dictSaleData
            mCourseAdEd.strToday = strToday
            mCourseAdEd.aryCourseDB = aryCourseDB
            mCourseAdEd.aryMember = aryMember
            mCourseAdEd.strMode = "edit"
        }
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        bolDataChange = false
        let dictData = mCourseAdEd.getPageData()
        
        if (dictData["rs"] as! Bool != true) {
            pubClass.popIsee(self, Msg: dictData["msg"] as! String)
            return
        }
        
        // 產生 http post data, http 連線儲存
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "coursesale"
        dictParm["act"] = "coursesale_updatedata"
        
        do {
            let tmpDictData = try
                NSJSONSerialization.dataWithJSONObject(dictData["data"] as! Dictionary<String, String>, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: tmpDictData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"))
            return
        }
        
        // HTTP 開始連線
        var errMsg = self.pubClass.getLang("err_trylatermsg")
        
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            // 回傳通知 parent 資料 reload
            if (dictHTTPSRS["result"] as! Bool == true) {
                errMsg = self.pubClass.getLang("datasavecompleted")
                self.bolDataChange = true
            }
            
            self.pubClass.popIsee(self, Msg: errMsg)
        })
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            self.delegate?.PageNeedReload!(self.bolDataChange)
        })
    }
    
}