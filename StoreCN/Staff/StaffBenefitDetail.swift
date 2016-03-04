//
// TableView
//

import UIKit
import Foundation

/**
 * 指定營養師，當月績效列表, 三個 section: 商品/療程/服務紀錄
 */
class StaffBenefitDetail: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labYYMM: UILabel!
    
    // common property
    private var pubClass: PubClass!
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var currYYMM: String!  // 目前的 yymm
    
    // 其他參數設定
    private let aryField = ["pd", "course", "count"]
    private var dictBenefit: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<Array<AnyObject>> = []
    private var strMM: String!  // ex. '07'
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // 重新產生 Table 需要的 Array data
        dictBenefit = dictAllData["benefit"] as! Dictionary<String, AnyObject>
        
        let aryField = ["pd", "course", "count"]
        for strField in aryField {
            if let tmpDict = dictBenefit[strField] as? Array<AnyObject> {
                aryTableData.append(tmpDict)
            } else {
                aryTableData.append([])
            }
        }
        
        // field 設定
        let strYY = pubClass.subStr(currYYMM, strFrom: 0, strEnd: 4)
        strMM = pubClass.subStr(currYYMM, strFrom: 4, strEnd: 6)
        labYYMM.text = strYY + " " + pubClass.getLang("mm_" + strMM)
        labName.text = dictAllData["usrname"] as? String
    }
    
    override func viewDidAppear(animated: Bool) {
        tableData.reloadData()
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {

    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return (aryTableData.count > 0) ? aryTableData[section].count : 0
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var ditItem: Dictionary<String, AnyObject> = [:]
        
        if let dictTmp = aryTableData[indexPath.section][indexPath.row] as? Dictionary<String, AnyObject> {
            ditItem = dictTmp
        }
        
        if (ditItem.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellStaffBenefitDetail", forIndexPath: indexPath) as! StaffBenefitDetailCell
        
        mCell.initView(ditItem, currMM: strMM, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // row 是否有資料
        var strNoData = " (" + pubClass.getLang("nodata") + ")"

        if let _ = dictBenefit[aryField[section]] as? Array<AnyObject> {
            strNoData = ""
        }
        
        return pubClass.getLang("staff_benefit_" + aryField[section]) + strNoData
    }
    
    /**
    * act, Segmented 績效選單 
    */
    @IBAction func actMenu(sender: UISegmentedControl) {
        let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: sender.selectedSegmentIndex)
        tableData.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}