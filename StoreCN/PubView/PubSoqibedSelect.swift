//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 會員產生的 SoqiBed 資料選擇 公用 class
 */
class PubSoqibedSelect: UITableViewController {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, paent 設定, Table DataSource, Soqibed 全部的檢測資料
    var arySoqibedData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    var strToday = ""
    private var newIndexPath: NSIndexPath!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        labNoData.alpha = 0.0
        
        if (self.arySoqibedData.count < 1) {
            self.labNoData.alpha = 1.0
        }
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {

    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return arySoqibedData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, Cell 使用 Table Cell 預設的樣式
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (arySoqibedData.count < 1) {
            return UITableViewCell()
        }
        
        // 取得 Item data source, CellView
        let ditItem = arySoqibedData[indexPath.row]
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPubSoqibedSelect")!
        
        // 使用時間 array data
        var strCounts = "0"
        if let aryTimes = ditItem["times"] as? Array<Dictionary<String, String>> {
            strCounts = String(aryTimes.count)
        }
        
        let strSDate = pubClass.formatDateWithStr(ditItem["sdate"] as? String, type: "8s")
        let strSubTitle = pubClass.getLang("soqibed_actdate") + ": " + strSDate + ", " + pubClass.getLang("soqibed_usecount") + ": " + strCounts
        
        mCell.textLabel?.text = ditItem["title"] as? String
        mCell.detailTextLabel?.text = strSubTitle
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // 取得選擇的 SOQIBED dict Data, 跳轉編輯頁面
        self.performSegueWithIdentifier("PubSoqibedAdEd", sender: arySoqibedData[indexPath.row])
    }
    
    /**
     * Segue 跳轉頁面，StoryBoard 介面需要拖曳 pressenting segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdentName = segue.identifier
        
        //  SOQIBED 編輯頁面
        if (strIdentName == "PubSoqibedAdEd") {
            let mVC = segue.destinationViewController as! PubSoqibedAdEd
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            mVC.strMode = "edit"
            
            return
        }
        
        return
    }
    
}