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
    @IBOutlet weak var labBTStat: UILabel!
    @IBOutlet weak var btnBTConn: UIButton!
    @IBOutlet weak var webScale: UIWebView!
    
    @IBOutlet weak var labVal_bmi: UILabel!
    @IBOutlet weak var labVal_fat: UILabel!
    @IBOutlet weak var labVal_water: UILabel!
    @IBOutlet weak var labVal_calory: UILabel!
    @IBOutlet weak var labVal_bone: UILabel!
    @IBOutlet weak var labVal_muscle: UILabel!
    @IBOutlet weak var labVal_vfat: UILabel!
    
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labMemberInfo: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    private var mBTScaleService: BTScaleService!  // 體脂計藍牙 Service
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // 回傳資料
    private var dictTableData: Dictionary<String, AnyObject> = [:]  // 本頁面欄位對應的資料
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
        dictTableData["member"] = [:]
        
        // 初始量測數值資料歸0
        for strScaleField in aryTestingField {
            dictTableData[strScaleField] = "0.0"
        }
        dictTableData["calory"] = "0"
        
        // 產生其他量測數值 UILabel 對應
        dictLabVal["bmi"] = labVal_bmi
        dictLabVal["fat"] = labVal_fat
        dictLabVal["water"] = labVal_water
        dictLabVal["calory"] = labVal_calory
        dictLabVal["bone"] = labVal_bone
        dictLabVal["muscle"] = labVal_muscle
        dictLabVal["vfat"] = labVal_vfat
        
        // view 相關 field
        btnBTConn.alpha = 0.1
        webScale.scrollView.scrollEnabled = false
        webScale.scrollView.bounces = false
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            bolReload = false
            self.btnBTConn.layer.cornerRadius = 5
            self.setViewChartHTML("0")
        }
    }
    
    /**
    * 本頁面 Table field 資料重新設定並重整
    */
    private func resetTableData() {
        // 量測數值 cell 設定
        for strScaleField in aryTestingField {
            if (strScaleField != "weight") {
                dictLabVal[strScaleField]!.text = dictTableData[strScaleField] as? String
            }
        }

        // 會員名稱與相關資料
        let strGender = pubClass.getLang("gender_" + (dictTableData["member"]!["gender"] as! String))
        let strAge = dictTableData["member"]!["age"] as! String + pubClass.getLang("name_age")
        let strHeight = dictTableData["member"]!["height"] as! String + "cm"
        let strMemberInfo = strGender + strAge + ", " + strHeight

        labMemberInfo.text = strMemberInfo
        labMemberName.text = dictTableData["member"]!["membername"] as? String
        
        // WebView chart 重新載入
        self.setViewChartHTML("0")
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
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        /* 第二個 section, 跳轉健康數值 '日曆頁面' */
    }
    
    /**
    * #mark: TestingMemberSel Delegate
    * 點取會員後執行相關程序
    */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        currIndexMember = MemberindexPath
        dictTableData["member"] = MemberData
        
        // 量測值全部歸0
        for strScaleField in aryTestingField {
            dictTableData[strScaleField] = "0.0"
        }
        dictTableData["calory"] = "0"
        
        // 本頁面 field 資料全部資料重設與重整
        self.resetTableData()
        
        // 體脂計 user 資料更新, 'gender', 'age', 'height'
        let dictUser = ["gender":MemberData["gender"] as! String, "age":MemberData["age"] as! String, "height":MemberData["height"] as! String]
        mBTScaleService.setUserData(dictUser)
        
        // button 藍芽連線
        btnBTConn.alpha = 1.0
    }
    
    /**
     * #mark: BTScaleServiceDelegate
     * 體脂計 Service class, handler
     */
    func handlerBLE(identCode: String!, result: Bool!, msg: String!, dictData: Dictionary<String, String>?) {

        switch (identCode) {
        case "BT_conn":
            if (result != true) {
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            
            labBTStat.text = msg
            
            break
            
        case "BT_statu":
            if (result != true) {
                mBTScaleService.BTDisconn()
                pubClass.popIsee(self, Msg: msg, withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
                return
            }
            
            labBTStat.text = msg
            
            break
            
        case "BT_data":
            break
            
        default:
            break
        }
    }
    
    /**
    * public, 斷開藍芽連線
    */
    func dicConnBT() {
        mBTScaleService.BTDisconn()
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
    * act, 點取藍芽 '連線' button
    */
    @IBAction func actBTConn(sender: UIButton) {
        mBTScaleService.BTConnStart()
    }
    
    
}