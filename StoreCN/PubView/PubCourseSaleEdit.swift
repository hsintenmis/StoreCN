//
// Container
//

import UIKit
import Foundation

/**
 * 公用, 會員療程銷售編輯
 */
class PubCourseSaleEdit: UIViewController {
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
    var mPubCourseSaleAdEd: PubCourseSaleAdEd!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // !! container 直接加入 ViewControler
        mPubCourseSaleAdEd = storyboard?.instantiateViewControllerWithIdentifier("PubCourseSaleAdEd") as! PubCourseSaleAdEd
        
        
        mPubCourseSaleAdEd.dictSaleData = dictSaleData
        mPubCourseSaleAdEd.strToday = strToday
        mPubCourseSaleAdEd.aryCourseDB = aryCourseDB
        mPubCourseSaleAdEd.aryMember = aryMember
        mPubCourseSaleAdEd.strMode = "edit"
        
        let mView = mPubCourseSaleAdEd.view
        mView.frame.size.height = contviewTable.layer.frame.height
        mView.frame.size.width = contviewTable.layer.frame.width
        
        contviewTable.addSubview(mView)
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        self.delegate?.PageNeedReload!(true)
        return
        
        let dictData = mPubCourseSaleAdEd.saveData()
        
        if (dictData["rs"] as! Bool != true) {
            pubClass.popIsee(self, Msg: dictData["msg"] as! String)
            return
        }
        
        // 產生 http post data, http 連線儲存後跳離
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
            // 回傳後跳離, 通知 parent 資料 reload
            if (dictHTTPSRS["result"] as! Bool == true) {
                errMsg = self.pubClass.getLang("datasavecompleted")
            }
            
            self.delegate?.PageNeedReload!(true)
        })
        
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}