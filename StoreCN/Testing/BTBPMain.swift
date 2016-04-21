//
// 本專案健康數值 item key: 高壓/低壓/心跳 "sbp", "dbp", "heartbeat"
//

import UIKit
import Foundation

/**
 * 血壓計主頁面
 */
class BTBPMain: UIViewController, TestingMemberSelDelegate, BTBPServiceDelegate {
    
    // @IBOutlet
    @IBOutlet weak var labBTStat: UILabel!
    @IBOutlet weak var labMember: UILabel!
    @IBOutlet weak var labVal_H: UILabel!
    @IBOutlet weak var labVal_L: UILabel!
    @IBOutlet weak var labVal_Beat: UILabel!
    @IBOutlet weak var btnConn: UIButton!
    @IBOutlet weak var btnMember: UIButton!

    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    private var mBTBPService: BTBPService!  // 血壓計藍牙 Service
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // 量測數值與會員資料
    
    // 檢測項目 key, val , lab 對應
    private var aryTestingField: Array<String> = ["sbp", "dbp", "heartbeat"]
    private var dictTestVal: Dictionary<String, String> = [:]
    private var dictTestUILabel: Dictionary<String, UILabel> = [:]
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BTScaleService 實體化與相關參數設定
        mBTBPService = BTBPService()
        mBTBPService.delegate = self
        
        // 欄位資料初始, 選擇的會員資料初始值 
        btnConn.alpha = 0.0
        btnConn.enabled = false
        btnConn.layer.cornerRadius = 5
        btnMember.layer.cornerRadius = 5
        
        dictRequest["member"] = [:]
        dictTestUILabel["sbp"] = labVal_H
        dictTestUILabel["dbp"] = labVal_L
        dictTestUILabel["heartbeat"] = labVal_Beat
        
        // 數值清除設定為 '0'
        clearTestingVal()
    }
    
    /**
     * 初始量測數值資料歸 0
     */
    private func clearTestingVal() {
        for strItem in aryTestingField {
            dictTestVal[strItem] = "0"
            dictTestUILabel[strItem]!.text = "0"
        }
    }
    
    /**
     * #mark: TestingMemberSel Delegate
     * 點取會員後執行相關程序
     */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        
        var strHeight = ""
        var strAge = ""
        var strGender = ""
        
        // 檢查必要欄位資料, height, gender, age
        if let mHeight = Float((MemberData["height"] as? String)!) {
            strHeight = String(Int(mHeight))
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_err_height"))
            return
        }
        
        if let mAge = Int((MemberData["age"] as? String)!) {
            if (mAge >= 5 && mAge <= 120) {
                strAge = String(Int(mAge))
            }
        }
        if (strAge == "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_err_age"))
            return
        }
        
        if let mGender = MemberData["gender"] as? String {
            if (mGender == "F" || mGender == "M") {
                strGender = mGender
            }
        }
        if (strGender == "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_err_gender"))
            return
        }
        
        // 設定參數 value
        currIndexMember = MemberindexPath
        dictRequest["member"] = MemberData
        
        // 會員名稱與相關資料重新顯示
        strGender = pubClass.getLang("gender_" + strGender)
        strAge += pubClass.getLang("name_age")
        strHeight += "cm"
        let strMemberInfo = strGender + strAge + ", " + strHeight
        
        labMember.text = dictRequest["member"]!["membername"] as? String
        //labMemberInfo.text = strMemberInfo
        
        // 量測值全部歸0
        clearTestingVal()
        
        // 其他 filed 設定, 顯示 BT conn button
        if (mBTBPService.BT_ISREADYFOTESTING == true) {
            labBTStat.text = pubClass.getLang("bt_btdeviceready")  // BT stat 訊息
            
            btnConn.alpha = 0.0
            btnConn.enabled = false
        } else {
            btnConn.alpha = 1.0
            btnConn.enabled = true
        }

    }
    
    /**
     * #mark: BTBPServiceDelegate
     * BT Device Service class, handler
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, dictData: Dictionary<String, AnyObject>?) {
        
        switch (identCode) {
        case "BT_conn":
            if (result != true) {
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                return
            }
            
            labBTStat.text = msg
            break
            
        case "BT_statu":
            if (result != true) {
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                return
            }
            
            labBTStat.text = msg
            
            // 搜尋不到藍芽設備=1, 手機藍牙未開=3
            if let code = dictData?["code"] as? Int {
                if (code == 1 || code == 3) {
                    btnConn.alpha = 1.0
                    btnConn.enabled = true
                    return
                }
                
                // 不能使用藍芽設備，跳離
                if (code == 2) {
                    btnConn.alpha = 0.0
                    pubClass.popIsee(self, Msg: msg, withHandler: {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    return
                }
            }
            
            break
            
        // 藍芽設備回傳資料
        case "BT_data":
            // 接收藍芽設備回傳數值，設定到 UILabel val_H/val_L/beat, String
            if (result == true) {
                dictTestUILabel["sbp"]!.text = dictData!["val_H"] as? String
                dictTestUILabel["dbp"]!.text = dictData!["val_L"] as? String
                dictTestUILabel["heartbeat"]!.text = dictData!["beat"] as? String
                
                if ((dictData!["val_H"] as! String) == "0") {
                    clearTestingVal()
                }
            }
            
            labBTStat.text = msg
            
            break
            
        default:
            break
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員選擇(公用)
        if (strIdent == "TestingMemberSel") {
            let mVC = segue.destinationViewController as! TestingMemberSel
            mVC.strToday = self.strToday
            mVC.aryMember = self.aryMember
            mVC.currIndexPath = self.currIndexMember
            mVC.delegate = self
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '選擇會員' button
     */
    @IBAction func actMember(sender: UIButton) {
        // 跳轉 '會員選擇' 頁面
        self.performSegueWithIdentifier("TestingMemberSel", sender: nil)
    }
    
    /**
     * act, 點取藍芽 '連線' button
     */
    @IBAction func actBTConn(sender: UIButton) {
        btnConn.alpha = 0.0
        btnConn.enabled = false
        
        mBTBPService.BTConnStart()
    }
    
    /**
     * act, 點取 '查看量測結果', 跳轉健康管理月曆主頁面
     */
    @IBAction func actToday(sender: UIBarButtonItem) {
        // 檢查有無選擇會員
        if (currIndexMember == nil) {
            pubClass.popIsee(self, Msg: pubClass.getLang("product_saleselmembermsg"))
            return
        }
        
        // 跳轉其他 storyboard VC
        pubClass.popIsee(self, Msg: pubClass.getLang("bt_savefirstseeresultmsg"), withHandler: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mVC = storyboard.instantiateViewControllerWithIdentifier("HealthCalendar") as! HealthCalendar
            mVC.dictMember = self.dictRequest["member"] as! Dictionary<String, AnyObject>
            self.presentViewController(mVC, animated: true, completion: nil)
        })
        
        return
    }
    
    /**
     * act, 點取 '儲存'
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        for strField in aryTestingField {
            dictRequest[strField] = dictTestUILabel[strField]!.text
        }
        
        // 檢查是否有資料
        if ( dictRequest["sbp"] as! String == "0" ) {
            pubClass.popIsee(self, Msg: pubClass.getLang("bt_testingvalerr"))
            
            return
        }
        
        self.saveProc()
    }
    
    /**
     * 資料儲存程序
     */
    private func saveProc() {
        // 整理要上傳的數值資料, 產生 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["sdate"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 8)
        dictArg0["age"] = dictRequest["member"]!["age"] as! String
        dictArg0["gender"] = dictRequest["member"]!["gender"] as! String
        
        // loop 已量測回傳的 val
        var dictTestingVal: Dictionary<String, String> = [:]
        dictTestingVal["height"] = dictRequest["member"]!["height"] as? String
        
        for strField in aryTestingField {
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
            self.mBTBPService.BTDisconn()
            //self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            return
        })
        
        return
    }
    
    /**
     * act, 點取 '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        // BT 強制中斷
        mBTBPService.BTDisconn()
        //self.dismissViewControllerAnimated(true, completion: nil)
        
        return
    }
    
}