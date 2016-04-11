//
// TableView
//

import UIKit
import Foundation

/**
 * 今日提醒, 預約療程/快過期療程/庫存, 共用 TableView
 */
class RemindList: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var segPage: UISegmentedControl!
    @IBOutlet weak var labTitle: UILabel!
    @IBOutlet weak var labCount: UILabel!
    
    // common property
    private var pubClass = PubClass()
    private var aryPageName = ["reser", "course", "stock"] // 各個 page 對應辨識名稱
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]  // 對應 table data
    var strToday: String!
    
    // 其他參數設定
    private var currPagePosition = 0
    private var strPageName: String!
    private var currTableData: Array<Dictionary<String, AnyObject>>!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 頁面 field 與相關參數初始
        segPage.selectedSegmentIndex = 0
        self.initPageData()
        
        // TableCell 自動調整高度
        tableData.estimatedRowHeight = 100.0
        tableData.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * viewDidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
    }
    
    /**
     * 頁面 field 與相關參數重設 value, 設定頁面上方 Title, 資料筆數訊息
     */
    private func initPageData() {
        strPageName = aryPageName[currPagePosition]
        currTableData = dictAllData[strPageName] as! Array<Dictionary<String, AnyObject>>
        
        labTitle.text = pubClass.getLang("remind_title_" + strPageName)
        labCount.text = String(currTableData.count)
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return currTableData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, 根據 'strPageName' 回傳對應的 CellView
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (currTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        var ditItem = currTableData[indexPath.row] as Dictionary<String, AnyObject>
        
        // 根據 'strPageName' 回傳對應的 CellView
        
        if (strPageName == "reser") {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellReservList", forIndexPath: indexPath) as! ReservListCell
            
            ditItem["coursename"] = ditItem["pdname"]
            mCell.initView(ditItem, PubClass: pubClass)
            
            return mCell
        }
        else if (strPageName == "course") {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellRemindCourse", forIndexPath: indexPath) as! RemindCourseCell
            mCell.initView(ditItem, PubClass: pubClass)
            
            return mCell
        }
        else if (strPageName == "stock") {
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellRemindStock", forIndexPath: indexPath) as! RemindStockCell
            mCell.initView(ditItem, PubClass: pubClass)
            
            return mCell
        }

        return UITableViewCell()
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
        //self.performSegueWithIdentifier("StaffAdEd", sender: aryData[indexPath.row])
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        let mVC = segue.destinationViewController as! StaffAdEd
        mVC.strMode = strMode
        mVC.dictMember = sender as! Dictionary<String, AnyObject>
        */
    }
    
    /**
     * act, 切換頁面 Segment
     */
    @IBAction func actPageChange(sender: UISegmentedControl) {
        currPagePosition = sender.selectedSegmentIndex
        
        // 頁面 field 與相關參數初始
        self.initPageData()
        tableData.reloadData()
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}