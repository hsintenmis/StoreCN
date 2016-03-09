//
// TableView
//

import UIKit
import Foundation

/**
 * 今日銷售總覽, 與'每月收入' Item click 進入本頁面，strType 判別
 */
class AnalyDataToday: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labDate: UILabel!
    
    @IBOutlet weak var labIncomePd: UILabel!
    @IBOutlet weak var labIncomeCourse: UILabel!
    @IBOutlet weak var labTotPrice: UILabel!
    @IBOutlet weak var labTotCustPrice: UILabel!
    @IBOutlet weak var labTotReturnPrice: UILabel!
    @IBOutlet weak var labIncome: UILabel!
    
    // common property
    private var pubClass: PubClass!
    
    // public, parent
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strToday: String!
    var strYYMMDD: String?  // 指定日期， parent 設定
    
    // 其他參數設定
    private let aryField = ["invoice", "course", "pd"] // table 三個 section field
    private var aryTableData: Array<Array<Dictionary<String, AnyObject>>> = []
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // TableCell autoheight
        tableData.estimatedRowHeight = 100.0
        tableData.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        chkHaveData()
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 檢查 "invoice", "course", "pd" 是否有資料, 設定到 aryTableData
        for strField in aryField {
            if let dictTmp = dictAllData[strField] as? Dictionary<String, Dictionary<String, AnyObject>> {
                
                // 轉換 dict to array
                var aryTmp: Array<Dictionary<String, AnyObject>> = []
                                
                let sortedDict = dictTmp.sort { $0.0 < $1.0 }
                
                for (key, value) in sortedDict {
                    var dictSub: Dictionary<String, AnyObject> = value
                    dictSub["id"] = key
                    aryTmp.append(dictSub)
                }
                
                aryTableData.append(aryTmp)
            }
            else {
                aryTableData.append([])
            }
        }
        
        // 本頁面資料重整
        tableData.reloadData()
        
        // 欄位資料設定
        if let _ = dictAllData["totIncome"] as? String {
            labIncomePd.text = dictAllData["totPdPrice"] as? String
            labIncomeCourse.text = dictAllData["totCoursePrice"] as? String
            labTotPrice.text = dictAllData["totSellPrice"] as? String
            labTotCustPrice.text = dictAllData["totcustprice"] as? String
            labTotReturnPrice.text = dictAllData["totreturn"] as? String
            labIncome.text = dictAllData["totIncome"] as? String
        }
        
        // 設定 YMD string
        var mDate = strToday
        if let tmpDate = strYYMMDD {
            mDate = tmpDate
        }
        
        if (mDate.characters.count >= 8) {
            labDate.text = pubClass.formatDateWithStr(mDate, type: 8)
        }
        else {
            let strDate = pubClass.subStr(mDate, strFrom: 0, strEnd: 4) + " " + pubClass.getLang("mm_" + pubClass.subStr(mDate, strFrom: 4, strEnd: 6))
            labDate.text = strDate
        }
    }

    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return aryField.count
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 row 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return (aryTableData.count > 0) ? aryTableData[section].count : 0
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let intSect = indexPath.section
        var ditItem: Dictionary<String, AnyObject> = [:]
        
        if let dictTmp: Dictionary<String, AnyObject> = aryTableData[intSect][indexPath.row] {
            ditItem = dictTmp
        }
        
        if (ditItem.count < 1) {
            return UITableViewCell()
        }
        
        // 根據 section 回傳產生不同的 UITableViewCell
        if (intSect == 0) {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellSheetInvoice", forIndexPath: indexPath) as! CellSheetInvoice
            mCell.initView(ditItem, PubClass: pubClass)
            return mCell
        }
        else if (intSect == 1) {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellSheetCourse", forIndexPath: indexPath) as! CellSheetCourse
            mCell.initView(ditItem, PubClass: pubClass)
            return mCell
        }
        else {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellSheetPd", forIndexPath: indexPath) as! CellSheetPd
            mCell.initView(ditItem, PubClass: pubClass)
            return mCell
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // row 是否有資料
        let strNoData = (aryTableData[section].count < 1) ? " (" + pubClass.getLang("nodata") + ")" : ""
        
        return pubClass.getLang("analydata_sheet_" + aryField[section]) + strNoData
    }
    
    /**
     * act, Segment, Table Section 選擇
     */
    @IBAction func actChangSect(sender: UISegmentedControl) {
        let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: sender.selectedSegmentIndex)
        tableData.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
}