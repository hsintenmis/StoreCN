//
// UITableViewController
//

import UIKit
import Foundation

/**
 * Mead 檢測資料列表與選擇, 公用 class
 */
class PubMeadDataSelect: UITableViewController {
    //var delegate = PubMeadDataSelectDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass = PubClass()
    
    // Table DataSource, Mead 全部的檢測資料, paent 設定
    var aryMeadData: Array<Dictionary<String, AnyObject>>?
    
    // 其他參數設定
    var strToday = ""
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labNoData.alpha = 0.0
        
        if (aryMeadData == nil) {
            self.labNoData.alpha = 1.0
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return (aryMeadData == nil) ? 0 : aryMeadData!.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryMeadData == nil) {
            return UITableViewCell()
        }
        
        let ditItem = aryMeadData![indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPubMeadDataSelect", forIndexPath: indexPath) as! PubMeadDataSelectCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        currIndexPath = indexPath
        var dictData = aryMeadData![indexPath.row]
        dictData["val"] = dictData["testing_val"]
        dictData["problem"] = dictData["problem_id"]
        
        self.performSegueWithIdentifier("RecordDetail", sender: dictData)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // MEAD 檢測報告頁面
        if (strIdent == "RecordDetail") {
            let mVC = segue.destinationViewController as! RecordDetail
            mVC.dictMeadData = sender as! Dictionary<String, String>
            
            return
        }
        
        return
    }
    
}