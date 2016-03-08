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
    var strYYMMDD: String?  // 指定日期， parent 設定
    
    // 本頁面需要的全部資料, http 連線取得
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var strToday: String!
    
    // 其他參數設定
    private let aryField = ["invoice", "course", "pd"] // table 三個 section field
    private var aryTableData: Array<Array<Dictionary<String, AnyObject>>> = []
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        
        // TODO test
        //strYYMMDD = "20160303"
        
        // TableCell autoheight
        tableData.estimatedRowHeight = 100.0
        tableData.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            reConnHTTP()
            bolReload = false
        }
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
                
                for (key, value) in dictTmp {
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
        
        var mDate = strToday
        if let tmpDate = strYYMMDD {
            mDate = tmpDate
        }
        labDate.text = pubClass.formatDateWithStr(mDate, type: 8)
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "analydata"
        mParam["act"] = "analydata_today"
        
        if let ymd = strYYMMDD {
            mParam["arg0"] = ymd
        }
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            self.strToday = dictData["today"] as! String
            self.dictAllData = dictData
            self.chkHaveData()
        })
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
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AnalyDataDaily") {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        return
    }
    
    /**
     * act, Segment, Table Section 選擇
     */
    @IBAction func actChangSect(sender: UISegmentedControl) {
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