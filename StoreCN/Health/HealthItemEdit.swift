//
// ViewControler 資料輸入 + WebView
//

import UIKit
import Foundation

/**
 * 健康數值資料輸入，Item 欄位變動
 */
class HealthItemEdit: UIViewController, UITextFieldDelegate {
    // WebHTML, 固定參數
    let D_BASE_FILENAME = "index"
    let D_BASE_URL = "html/html_cn"
    
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var navyTopBar: UINavigationItem!
    @IBOutlet weak var webHealth: UIWebView!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet var colLabName: [UILabel]!
    @IBOutlet var colLabUnit: [UILabel]!
    @IBOutlet var txtVal: [UITextField]!
    
    // common property
    private var pubClass = PubClass()
    
    // public parent 設定, 全部的檢測資料數值 dict array
    var dictAllData: Dictionary<String, Dictionary<String, String>> = [:]
    
    // public parent 設定, 指定的檢測項目 key name, ex. 'bmi', 參考 'HealthDataInit'
    var strItemKey = ""
    
    // public parent 設定, 日期資料, 會員資料
    var dictCurrDate: Dictionary<String, String> = [:]
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定: group key, 本頁面資料是否有上傳變動，上層 class 刷新
    private var strGroup = ""
    private var isDataSave = false;
    private var currentTextField: UITextField?  // 目前選擇的 txtView, keyboard相關
    
    // other class import, 健康項目資料產生整理好的資料 class
    private var mHealthDataInit = HealthDataInit()
    
    // 本 class 實際的健康項目與數值 array
    private var dictCurrHealth: Array<Dictionary<String, String>>! = []
    
    // class, 解釋健康檢測資料，計算特殊欄位數值
    private var mHealthExplainTestData = HealthExplainTestData()
    
    /**
    * View load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定頁面顯示資料
        self.setCurrHeatthData()
        self.setFieldData()
        self.setHTMLView()
        
        navyTopBar.title = pubClass.getLang("healthgroup_" + strGroup)
        labSdate.text = dictCurrDate["YY"]! + " / " + dictCurrDate["MM"]! + " / " + dictCurrDate["DD"]!
    }
    
    /**
     * 根據檢測項目的 key name, 以 key 'group' 重新產生本 class 需要的資料集
     * 回傳如: ary(dict0, dict1 ...), dict = ('field'=> 'val', ...)
     */
    private func setCurrHeatthData() {
        // 取得 group key
        strGroup = dictAllData[strItemKey]!["group"]!
        
        // loop data 取得相同 group data
        for strKey in mHealthDataInit.D_HEALTHITEMKEY {
            let dictItem = dictAllData[strKey]!
            if (dictItem["group"] == strGroup) {
                dictCurrHealth.append(dictItem)
            }
        }
    }
    
    /**
     * 設定健康數值輸入的：欄位名稱/單位/數值
     */
    private func setFieldData() {
        // 相關欄位預設 disable
        for loopi in (0..<3) {
            colLabName[loopi].alpha = 0.0
            colLabUnit[loopi].alpha = 0.0
            txtVal[loopi].alpha = 0.0
            txtVal[loopi].enabled = false
        }
        
        // loop data, 設定 @IBOutlet val
        for loopi in (0..<dictCurrHealth.count) {
            let dictItem = dictCurrHealth[loopi]
            colLabName[loopi].text = dictItem["name"]
            colLabUnit[loopi].text = dictItem["unit"]
            txtVal[loopi].text = dictItem["val"]
            
            colLabName[loopi].alpha = 1.0
            colLabUnit[loopi].alpha = 1.0
            txtVal[loopi].alpha = 1.0
            txtVal[loopi].enabled = true
            
            // 手動設定 textView Delegate
            txtVal[loopi].delegate = self
            
            // 欄位 'height' 身高預設值處理
            if (dictItem["field"] == "height") {
                let intValue: Int = NSString(string: dictItem["val"]!).integerValue
                if (intValue < 1) {
                    txtVal[loopi].text = dictMember["height"] as? String
                }
            }
        }
    }
    
    /**
     * 顯示 HTML view
     */
    private func setHTMLView() {
        // 取得 HTML base path
        let baseFile = NSBundle.mainBundle().pathForResource(D_BASE_FILENAME, ofType: "html", inDirectory: D_BASE_URL)!
        let baseUrl = NSURL(fileURLWithPath: baseFile)
        
        // 取得指定 HTML 檔案, 若無檔案 return
        let strHTMLFileName = strGroup + "_info"
        
        if let htmlFile = NSBundle.mainBundle().pathForResource(strHTMLFileName, ofType: "html", inDirectory: D_BASE_URL) {
            do {
                let strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
                self.webHealth.loadHTMLString(strHTML as String, baseURL: baseUrl)
            } catch {
                // 資料錯誤
                //print("err")
                return
            }
        }
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 取得並設定目前選擇的 textView
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 動態檢查 textView 輸入字元數目, TextView 需要設定 delegate
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 5
        let currentString: NSString = textField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        
        return newString.length <= maxLength
    }
    
    /**
     * #mark: UITextFieldDelegate
     * KB 點取 'return'
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    /**
     * btn '儲存' 點取
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 關閉虛擬鍵盤
        if (currentTextField != nil) {
            currentTextField!.resignFirstResponder()
        }
        
        // 健康測量, key, val 加入新的 dict, 檢查輸入的資料
        var dictItemNew: Dictionary<String, String> = [:]
        for loopi in (0..<dictCurrHealth.count) {
            
            if let _ = Float(txtVal[loopi].text!) {
                // 加入 健康測量, key, val
                let dictTmp = dictCurrHealth[loopi]
                dictItemNew[dictTmp["field"]!] = txtVal[loopi].text
            } else {
                pubClass.popIsee(self, Msg: pubClass.getLang("healthvalinputerr"))
                return
            }
            
            /*
            if (txtVal[loopi].text == "") {
                pubClass.popIsee(self, Msg: pubClass.getLang("healthvalinputerr"))
                return
            }
            */
        }
        
        // 特殊欄位需要計算, group='bmi', 'whr', 的數值顯示於 textView
        if (strGroup == "bmi" || strGroup == "whr") {
            dictItemNew = mHealthExplainTestData.CalHealthData(strGroup, jobjItem: dictItemNew)

            // 重新顯示 TextView 欄位
            for loopi in (0..<dictCurrHealth.count) {
                let strField = dictCurrHealth[loopi]["field"]!
                txtVal[loopi].text = dictItemNew[strField]
            }
        }
        
        // 產生 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        
        dictArg0["age"] = dictMember["age"]
        dictArg0["gender"] = dictMember["gender"]
        dictArg0["sdate"] = dictCurrDate["YY"]! + dictCurrDate["MM"]! + dictCurrDate["DD"]!
        dictArg0["data"] = dictItemNew
        
        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "health"
        dictParm["act"] = "health_savehealthdata"
        dictParm["arg1"] = dictMember["memberid"] as? String
        
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
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("healthvalsavecompleted"))
                self.isDataSave = true
                
                return
            }
            
            // 儲存失敗
            self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        return
    }
    
    /**
     * btn '返回' 點取
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        // 本頁面資料有儲存，通知 parent
        if (isDataSave) {
            delegate?.PageNeedReload!(true)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}