//
// ScrollView
//

import UIKit
import Foundation

/**
 * 主選單
 */
class MainMenu: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var labTodayMsg: UILabel!

    
    // public property
    var mVCtrl: UIViewController!
    let pubClass = PubClass()
    let mJSONClass = JSONClass()
    let mFileMang = FileMang()
    
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // parent Segue 設定
    var aryMember: Array<Dictionary<String, String>> = []
    var aryPict: Dictionary<String, String> = [:]
    
    // 產生 UIAlertController (popWindow 資料傳送中)
    var vcPopLoading: UIAlertController!
    
    // 其他參數設定
    var strToday = ""
    var strTodayMsg = ""
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillAppear(animated: Bool) {

    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        
        self.pubClass.ReloadAppDelg()
        dictPref = pubClass.getPrefData()
        
        dispatch_async(dispatch_get_main_queue(), {
            // 連線取得資料
            self.StartHTTPConn()
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        labTodayMsg.text = strTodayMsg
    }
    
    /**
     * 登入後主選單，連線取得資料
     */
    func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "homepage";
        dictParm["act"] = "homepage_remindall";
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVCtrl, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果, 實作給 'pubClass.startHTTPConn()' 使用，callback function
     */
    func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        /* 解析正確的 http 回傳結果，執行後續動作 */
        let dictData = (dictRS["data"]!["content"]!)!
        
        // 今天日期
        strToday = dictData["today"] as! String
        
        // 今日預約療程資料
        var aryTodayCourse: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["reser"] as? Array<Dictionary<String, AnyObject>> {
            aryTodayCourse = aryData
        }
        
        // 療程快到期資料
        var aryExpire: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["course"] {
            aryExpire = aryData as! Array<Dictionary<String, AnyObject>>
        }
        
        // 庫存不足商品
        var aryStock: Array<Dictionary<String, AnyObject>> = []
        if let aryData = dictData["stock"] {
            aryStock = aryData as! Array<Dictionary<String, AnyObject>>
        }
        
        // 產生'今日提醒文字'
        strTodayMsg = "今日有\(aryTodayCourse.count)筆療程預約, \(aryExpire.count)名會員療程快到期, \(aryStock.count)項商品庫存不足."
        
        initViewField()
    }
    
    /**
     * act, 點取 '登出' button
     */
    @IBAction func actLogout(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    /**
     * act, 點取 '刷新' button
     */
    @IBAction func actReload(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_main_queue(), {
            // 連線取得資料
            self.StartHTTPConn()
        })
        
        self.pubClass.ReloadAppDelg()
        dictPref = pubClass.getPrefData()
        initViewField()
    }
    

}

