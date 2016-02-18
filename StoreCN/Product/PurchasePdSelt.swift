//
// TableView
//

import UIKit
import Foundation

/**
 * protocol, PurchasePdSelt Delegate
 */
protocol PurchasePdSeltDelegate {
    /**
     * 本頁面點取'完成'btn, 回傳已變動的全部商品 array data
     */
    func PdSeltPageDone(PdAllData dictData: Dictionary<String, Array<Dictionary<String, String>>>)
}

/**
 * 商品選擇，從進貨新增頁面轉入 (店家進貨)
 */
class PurchasePdSelt: UIViewController, PickerQtyDelegate {
    // protocol delegate
    var delegate = PurchasePdSeltDelegate?()
    
    // 商品分類
    private let aryPdType = ["S", "C", "N"]
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var edQty: UITextField!
    
    // common property
    let pubClass: PubClass = PubClass()
    var mPickerQty: PickerQty!
    
    // public, 從 parent 設定
    var strToday = ""
    var dictCategoryPd: Dictionary<String, Array<Dictionary<String, String>>> = [:] // 已經分類完成的商品

    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        edQty.alpha = 0.0
        
        //tableData.layer.frame.size.height
        
        mPickerQty = PickerQty(parentView: self.view, tableView: tableData, edView: edQty, DefVal: 5, MinMaxAry: [0, 99], NavyBarTitle: pubClass.getLang("peoduct_selectqty"))
        
        mPickerQty.delegate = self
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pubClass.getLang("peoduct_ptype_" + aryPdType[section])
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.aryPdType.count
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        let strKey = aryPdType[section]
        return dictCategoryPd[strKey]!.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 取得指定 section 的 array data
        let strKey = aryPdType[indexPath.section]
        let aryPd = dictCategoryPd[strKey]!
        
        if (aryPd.count < 1) {
            return UITableViewCell()
        }

        // 產生 Item data
        let ditItem = aryPd[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPurchasePdSelt", forIndexPath: indexPath) as! PurchasePdSeltCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 取得指定 section 的 array data
        let strKey = aryPdType[indexPath.section]
        let aryPd = dictCategoryPd[strKey]!
        let dictPd = aryPd[indexPath.row]
        
        mPickerQty.ShowQtyView(DefaultVal: Int(dictPd["qtySel"]!)!, tableIndexPath: indexPath)
    }
    
    /**
     * #mark: PickerQtyDelegate
     * 點取 '完成' 回傳選擇的 qty
     */
    func QtySelecteDone(SelectQty: Int) {
        print(SelectQty)
    }
     
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * act, 點取 '完成' button
     */
    @IBAction func actDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            self.delegate?.PdSeltPageDone(PdAllData: self.dictCategoryPd)
        })
    }
    
}

