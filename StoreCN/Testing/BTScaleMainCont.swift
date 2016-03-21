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
class BTScaleMainCont: UITableViewController, TestingMemberSelDelegate {
    
    // 公用, 固定參數，體指計數值對應參數(注意順序)
    let aryTestingField: Array<String> = ["weight", "bmi", "fat", "water", "calory", "bone", "muscle", "vfat"]
    
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
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // 回傳資料
    private var dictTableData: Dictionary<String, AnyObject> = [:]  // 本頁面欄位對應的資料
    private var dictLabVal: Dictionary<String, UILabel> = [:] // 產生其他量測數值 UILabel 對應
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {

    }
    
    /**
    * Table 資料重新設定並重整
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
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 體脂計主頁面
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
    }
    
    
}