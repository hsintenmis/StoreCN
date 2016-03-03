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
    
    // common property
    private var pubClass: PubClass!
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var dictBenefit: Dictionary<String, AnyObject> = [:]
    private var aryTableData: Array<Array<AnyObject>> = []

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
    }
    
    override func viewDidAppear(animated: Bool) {

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
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        let dictSectData = aryTableData[indexPath.section]

        
        // 產生 Item data
        let ditItem = [indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellStaffList", forIndexPath: indexPath) as! StaffListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pubClass.getLang("staff_totnums") + ": " + String(aryData.count)
    }
    
    /**
    * act, Segmented 績效選單 
    */
    @IBAction func actMenu(sender: UISegmentedControl) {
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}