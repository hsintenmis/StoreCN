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
    @IBOutlet weak var labBTStat: UILabel!
    @IBOutlet weak var btnBTConn: UIButton!
    @IBOutlet weak var webScale: UIWebView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // 回傳資料
    private var dictTableData: Dictionary<String, AnyObject> = [:]  // Table 資料
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 初始 table 資料 */
        dictTableData["member"] = [:]
        
        // 初始量測數值資料
        for strScaleField in aryTestingField {
            dictTableData[strScaleField] = "0.0"
        }
        dictTableData["calory"] = "0"
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
        
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, 不同 cell 初始對應的 cell class
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let intSect = indexPath.section
        
        
        
        /* 第二個 section, 顯示量測數值 */
        /*
        if (intSect == 0) {
            // 取得 Item data source, CellView
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseDefSel")!
            
            mCell.textLabel?.text = ditItem["pdname"] as? String
            mCell.detailTextLabel?.text = ditItem["pdid"] as? String
            
            return mCell
        }
        */
    }

    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        /* 第二個 section, 跳轉健康數值 '日曆頁面' */
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        /* 第ㄧ個 section, 顯示會員身高，年齡資料 */
        return ""
    }
    
    /**
    * #mark: TestingMemberSel Delegate
    * 點取會員後執行相關程序
    */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        currIndexMember = MemberindexPath
        
        // 本頁面資料全部資料重設與重整
        print(MemberData)
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