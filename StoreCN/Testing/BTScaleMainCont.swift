//
// Container 轉入, Static TableView 主頁面
//
//

import UIKit
import Foundation

/**
 * 體脂計頁面, parent Container 轉入
 * 本 table 有2個 section
 */
class BTScaleMainCont: UITableViewController, TestingMemberSelDelegate, BTScaleServiceDelegate {
    
    // !!TODO!! WebHTML, 圖表固定參數
    private let D_HTML_FILENAME = "weight"
    private let D_HTML_URL = "html/weight"
    private let D_BASE_FILENAME = "index"
    private let D_BASE_URL = "html"
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var webScale: UIWebView!
    
    @IBOutlet weak var labBTStat: UILabel!
    @IBOutlet weak var labVal_bmi: UILabel!
    @IBOutlet weak var labVal_fat: UILabel!
    @IBOutlet weak var labVal_water: UILabel!
    @IBOutlet weak var labVal_calory: UILabel!
    @IBOutlet weak var labVal_bone: UILabel!
    @IBOutlet weak var labVal_muscle: UILabel!
    @IBOutlet weak var labVal_vfat: UILabel!
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labMemberInfo: UILabel!
    
    @IBOutlet weak var btnBTConn: UIButton!
    @IBOutlet weak var btnTestExplain: UIButton!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    private var mBTScaleService: BTScaleService!  // 體脂計藍牙 Service
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // 量測數值與會員資料
    private var dictLabVal: Dictionary<String, UILabel> = [:] // 產生其他量測數值 UILabel 對應
    
    // 體指計數值對應參數, value 來自'BTScaleService'
    private var aryTestingField: Array<String>!
    private var bolReload = true
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BTScaleService 實體化與相關參數設定
        mBTScaleService = BTScaleService()
        mBTScaleService.delegate = self
        aryTestingField = mBTScaleService.aryTestingField
        
        // 選擇的會員資料初始值
        dictRequest["member"] = [:]
        
        // 初始量測數值資料歸0
        clearTestingVal()
        
        // 產生其他量測數值 UILabel 對應
        dictLabVal["bmi"] = labVal_bmi
        dictLabVal["fat"] = labVal_fat
        dictLabVal["water"] = labVal_water
        dictLabVal["calory"] = labVal_calory
        dictLabVal["bone"] = labVal_bone
        dictLabVal["muscle"] = labVal_muscle
        dictLabVal["vfat"] = labVal_vfat
        
        // view 相關 field
        webScale.scrollView.scrollEnabled = false
        webScale.scrollView.bounces = false
        
        btnBTConn.alpha = 0.0
        btnTestExplain.alpha = 0.0
        
        btnBTConn.layer.cornerRadius = 5
        btnTestExplain.layer.cornerRadius = 5
        setViewChartHTML("0")
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            bolReload = false
        }
    }
    
    /**
     * // 初始量測數值資料歸 0
     */
    private func clearTestingVal() {
        for strScaleField in aryTestingField {
            dictRequest[strScaleField] = "0.0"
        }
        dictRequest["calory"] = "0"
    }
    
    /**
     * WebView 體重計 HTML 顯示<P>
     * 設定 Chart view, 設定到 UIWebView
     */
    private func setViewChartHTML(strWeight: String = "0") {
        // 取得原始 HTML String code
        do {
            let htmlFile = NSBundle.mainBundle().pathForResource(D_HTML_FILENAME, ofType: "html", inDirectory: D_HTML_URL)!
            var strHTML = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
            
            // TODO 開始執行字串取代
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_HEIGHT", withString: "320px");
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_CHART_WIDTH", withString: "100%");
            strHTML = strHTML.stringByReplacingOccurrencesOfString("D_VAL", withString: strWeight);
            
            // 以 HTML code 產生新的 WebView
            let baseFile = NSBundle.mainBundle().pathForResource(D_BASE_FILENAME, ofType: "html", inDirectory: D_BASE_URL)!
            let baseUrl = NSURL(fileURLWithPath: baseFile)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.webScale.loadHTMLString(strHTML as String, baseURL: baseUrl)
            })
            
        } catch {
            // 資料錯誤
            //print("err")
            return
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
        
        labMemberInfo.text = strMemberInfo
        labMemberName.text = dictRequest["member"]!["membername"] as? String
        
        // 量測值全部歸0
        clearTestingVal()
        
        // 本頁面數值資料重設並重整
        self.resetValData()
        
        // 體脂計 user 資料更新, 'gender', 'age', 'height'
        let dictUser = ["gender":MemberData["gender"] as! String, "age":MemberData["age"] as! String, "height":MemberData["height"] as! String]
        mBTScaleService.setUserData(dictUser)
        
        // 其他 filed 設定
        if (mBTScaleService.BT_ISREADYFOTESTING == true) {
            labBTStat.text = pubClass.getLang("bt_btdeviceready")  // BT stat 訊息
        } else {
            btnBTConn.alpha = 1.0  // button, 藍芽連線
            btnTestExplain.alpha = 1.0
        }
    }
    
    /**
     * 本頁面數值資料重設並重整
     */
    private func resetValData() {
        // 量測數值 cell 設定
        for strScaleField in aryTestingField {
            if (strScaleField != "weight") {
                dictLabVal[strScaleField]!.text = dictRequest[strScaleField] as? String
            }
        }
        
        // WebView chart 重新載入
        self.setViewChartHTML(dictRequest["weight"] as! String)
    }
    
    /**
     * #mark: BTScaleServiceDelegate
     * 體脂計 Service class, handler
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, dictData: Dictionary<String, String>?) {

        switch (identCode) {
        case "BT_conn":
            // 藍牙斷線，一定跳離 VC
            if (result != true) {
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            
            btnBTConn.alpha = 0.0
            btnBTConn.enabled = false
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
            
            break
            
        // 藍芽設備回傳資料
        case "BT_data":
            // 回傳資料重新設定到 'dictTableData'
            if (result == true) {
                for strScaleField in aryTestingField {
                    dictRequest[strScaleField] = dictData![strScaleField]
                }
            } else {
                // 量測值全部歸0
                clearTestingVal()
            }
            
            self.resetValData()
            labBTStat.text = msg
            
            break
            
        default:
            break
        }
    }
    
    /**
    * public, parent 調用, 斷開藍芽連線
    */
    func dicConnBT() {
        mBTScaleService.BTDisconn()
        return
    }
    
    /**
     * public, parent 調用, 回傳量測數值與相關資料
     */
    func getTestingData() -> Dictionary<String, AnyObject>! {
        return dictRequest
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
     * act, 點取 '查看量測結果', 跳轉健康管理月曆主頁面
     */
    @IBAction func actTestExplain(sender: UIButton) {
        pubClass.popIsee(self, Msg: pubClass.getLang("bt_savefirstseeresultmsg"), withHandler: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mVC = storyboard.instantiateViewControllerWithIdentifier("HealthCalendar") as! HealthCalendar
            mVC.dictMember = self.dictRequest["member"] as! Dictionary<String, AnyObject>
            self.presentViewController(mVC, animated: true, completion: nil)
        })

        return
    }
    
    /**
    * act, 點取藍芽 '連線' button
    */
    @IBAction func actBTConn(sender: UIButton) {
        mBTScaleService.BTConnStart()
    }
    
    
}