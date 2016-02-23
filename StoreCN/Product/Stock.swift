//
// TableView
//

import UIKit
import Foundation

/**
 * !TODO! table cell 點取有權限
 *
 * 商品管理 - 庫存
 */
class Stock: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // table data 設定
    private var aryStock: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        
        // 檢查資料
        if let tmpData = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryStock = tmpData
        }
        
        // 檢查是否有資料
        if (aryStock.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("nodata"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
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
        return aryStock.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryStock.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryStock[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellStock", forIndexPath: indexPath) as! StockCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("StockHistory", sender: aryStock[indexPath.row])
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 進出貨歷史頁面
        if (strIdent == "StockHistory") {
            let mVC = segue.destinationViewController as! StockHistory
            mVC.dictData = sender as! Dictionary<String, AnyObject>
            
            return
        }
    }
    
    /**
     * act, 點取 '排序' button
     */
    @IBAction func actSort(sender: UIBarButtonItem) {
        let nums = aryStock.count
        var loopi = 0
        var aryStockNew: Array<Dictionary<String, AnyObject>> = []
        
        for (loopi = (nums - 1); loopi >= 0; loopi--) {
            aryStockNew.append(aryStock[loopi])
        }
        
        aryStock = aryStockNew
        tableData.reloadData()
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}