//
// Container, 跳轉 Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * 氧身工程模式，目前僅設定SOQIBed床組
 * <P>
 * 會員使用模式資料, 新增/編輯刪除<BR>
 * 各個裝置(H01, H02..)都需要設定預設值
 * <P>
 * 資料產生方式:<BR>
 * 1. MEAD檢測結果產生<br>
 * 2. 購買療程<br>
 * 3. 自行輸入
 */
class PubSoqibedAdEd: UIViewController {
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strMode = "edit" // 目前頁面模式, 'add' or 'edit'
    var strIsDel = "N" // 標記資料刪除
    var isUpdateData = false // 本頁面資料是否有更動
    
    // 資料存檔使用
    /*
    private Intent intentParent; // parent 傳入的 intent
    private String strID_Mead, strID_Course; // Mead, 療程對應的 'ID'
    private JSONObject jobjDevTime = null; // 各裝置的分鐘數, ex. 'H01' : "30"...
    private String strMemberId = "", strMemberName = "";
    private String strIndex_id = "";
    private String strTitle = "";
    */
    
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
        
        // Container 轉入體脂計主頁面
        if (strIdent == "BTScaleMainCont") {
            mBTScaleMainCont = segue.destinationViewController as! BTScaleMainCont
            mBTScaleMainCont.strToday = self.strToday
            mBTScaleMainCont.aryMember = self.aryMember
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictRequest = mBTScaleMainCont.getTestingData()
        
        // 檢查是否有資料， 'weight' 數值判別
        if ( Float(dictRequest["weight"] as! String) < 1.0 ) {
            pubClass.popIsee(self, Msg: pubClass.getLang("bt_testingvalerr"))
            
            return
        }
        
        // 整理要上傳的數值資料, 產生 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["sdate"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 8)
        dictArg0["age"] = dictRequest["member"]!["age"] as! String
        dictArg0["gender"] = dictRequest["member"]!["gender"] as! String
        
        // loop 以量測回傳的 val
        var dictTestingVal: Dictionary<String, String> = [:]
        dictTestingVal["height"] = dictRequest["member"]!["height"] as? String
        
        for strField in BTScaleService().aryTestingField {
            dictTestingVal[strField] = dictRequest[strField]! as? String
        }
        
        dictArg0["data"] = dictTestingVal
        
        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "health"
        dictParm["act"] = "health_savehealthdata"
        dictParm["arg1"] = dictRequest["member"]!["memberid"] as? String
        
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
            
            // 儲存成功
            if (dictHTTPSRS["result"] as! Bool == true) {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("datasavecompleted"))
                return
            }
            
            // 儲存失敗，直接跳離
            self.mBTScaleMainCont.dicConnBT()
            self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        return
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        // BT 強制中斷
        mBTScaleMainCont.dicConnBT()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}