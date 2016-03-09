//
// TableView
//

import UIKit
import Foundation

/**
 * 每月銷售列表, 商品/療程 總收入
 */
class AnalyDataMonthly: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    private var pubClass: PubClass!
    
    // public, parent
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strToday: String!
    
    // 其他參數設定
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadPage()
    }
    
    /**
     * 頁面重整
     */
    private func reloadPage() {
        // 設定目前的 table data source
        aryTableData = dictAllData["data"] as! Array<Dictionary<String, AnyObject>>
        tableData.reloadData()
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
     * 回傳指定 row 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryTableData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellAnalyDataMonthly", forIndexPath: indexPath) as! AnalyDataMonthlyCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 顯示指定日期收入報表
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 產生 'YYMM' string
        let dictItem = aryTableData[indexPath.row] as Dictionary<String, AnyObject>
        let strYMD = dictItem["yymm"] as! String
        
        self.performSegueWithIdentifier("AnalyDataMonthlyDetail", sender: strYMD)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AnalyDataMonthlyDetail") {
            let mVC = segue.destinationViewController as! AnalyDataMonthlyDetail
            mVC.strYYMMDD = sender as! String
            
            return
        }
        
        return
    }
    
}