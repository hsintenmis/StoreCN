//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 設定 - 店家基本資料
 */
class ConfigProfile: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    var pubClass: PubClass!
    
    // child editpage class, 'ConfigCourseEdit'
    private var mConfigProfileEdit: ConfigProfileEdit!

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
        mConfigProfileEdit = segue.destinationViewController as! ConfigProfileEdit
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictData = mConfigProfileEdit.getPageData()
        
        // 必填欄位檢查
        var strErr = ""
        let aryChkField = ["edStoreName", "edTel", "edStoreMaster"]
        
        for strField in aryChkField {
            if (dictData[strField] == "") {
                strErr += (pubClass.getLang("config_profile_err_" + strField) + "\n")
            }
        }
        
        if (strErr != "") {
            pubClass.popIsee(self, Msg: strErr)
            return
        }
        
        // 產生 http post data, http 連線儲存後跳離
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "homepage"
        dictParm["act"] = "homepage_savestoreprofile"
        
        do {
            let tmpDictData = try
                NSJSONSerialization.dataWithJSONObject(dictData!, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: tmpDictData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_data"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            return
        }
        
        // HTTP 開始連線
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: self.HttpSaveResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 回傳後跳離, 通知 parent 資料 reload
        let strMsg = (dictRS["result"] as! Bool != true) ? pubClass.getLang("err_trylatermsg") : pubClass.getLang("datasavecompleted")
        
        pubClass.popIsee(self, Msg: strMsg)
    }

    /**
     * act, btn '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}