//
// TableView
//

import UIKit
import Foundation

/**
 * 商品管理 - 庫存進出貨歷史紀錄
 */
class StockHistory: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labPdName: UILabel!
    @IBOutlet weak var labPdId: UILabel!
    @IBOutlet weak var labQty: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictData: Dictionary<String, AnyObject>!
    
    // 其他參數設定
    private var aryData: Array<Dictionary<String, String>>!  // table data
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        aryData = dictData["history"] as! Array<Dictionary<String, String>>
        
        labPdName.text = dictData["pdname"] as? String
        labPdId.text = dictData["pdid"] as? String
        labQty.text = dictData["qty"] as? String
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
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
        return aryData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryData[indexPath.row] as Dictionary<String, String>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellStockHistory", forIndexPath: indexPath) as! StockHistoryCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}