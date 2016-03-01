//
// TableView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨退回列表
 */
class PurchaseReturnList: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labPriceCust: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject>!
    
    // table data 設定
    private var aryData: Array<Dictionary<String, AnyObject>>! // 退貨資料 array
    
    // 原始進貨商品 dict 資料，用於計算最大退貨量, 'pdid' => qty dict data
    private var dictPurchasePd: Dictionary<String, Dictionary<String, AnyObject>> = [:]
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        aryData = dictAllData["return"] as! Array<Dictionary<String, AnyObject>>
        
        // 產生原始進貨商品 dict 資料，用於計算最大退貨量
        for dictTmp in dictAllData["pd"] as! Array<Dictionary<String, AnyObject>> {
            let pdid = dictTmp["pdid"] as! String
            var dictPdAddData: Dictionary<String, AnyObject> = [:]
            
            dictPdAddData["qty"] = dictTmp["pdid"] as! String
            dictPdAddData["totRQty"] = dictTmp["totRQty"] as! String
            dictPdAddData["maxqty"] = dictTmp["maxqty"] as! String
            
            dictPurchasePd[pdid] = dictPdAddData
        }
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        labPrice.text = dictAllData["returnprice"] as? String
        labPriceCust.text = dictAllData["returnpricecust"] as? String
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
        let ditItem = aryData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPurchaseReturnList", forIndexPath: indexPath) as! PurchaseReturnListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("PurchaseReturnEdit", sender: aryData[indexPath.row])
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 進貨退回，編輯退貨項目與相關資料
        if (strIdent == "PurchaseReturnEdit") {
            let mVC = segue.destinationViewController as! PurchaseReturnEdit
            mVC.dictReturn = sender as! Dictionary<String, AnyObject>
            mVC.strToday = strToday
            mVC.dictPurchasePd = dictPurchasePd
            mVC.purchaseDate = dictAllData["sdate"] as! String
            
            return
        }
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}