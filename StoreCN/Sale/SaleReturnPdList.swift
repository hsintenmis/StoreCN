//
// UITableViewController, data value change
//

import UIKit
import Foundation

/**
 * protocol, PubPurReturnPdList Delegate
 */
protocol SaleReturnPdListDelegate {
    /**
     * Table Cell 的 editView 商品數量改變
     */
    func PdQtyChange(SelectQty: Int, indexPath: NSIndexPath)
}

/**
 * 退貨商品列表，指定日期(退貨單號)的退貨商品列表
 */
class SaleReturnPdList: UITableViewController, SaleReturnPdCellDelegate {
    var delegate = SaleReturnPdListDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    let pubClass = PubClass()
    
    // parent 設定, 指定日期的退貨資料 array data
    var aryData: Array<Dictionary<String, AnyObject>>!
    var strToday: String!
    
    // 其他參數設定
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳 section 指定的數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryData.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = aryData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSaleReturnPd", forIndexPath: indexPath) as! SaleReturnPdCell
        
        mCell.delegate = self
        mCell.initView(ditItem, forIndexPath: indexPath)
        
        return mCell
    }
    
    /**
     * #mark: PubPurReturnPdListCell Delegate
     * 數量選擇確認
     */
    func QtySelecteDone(SelectQty: Int, indexPath: NSIndexPath) {
        aryData[indexPath.row]["selQty"] = String(SelectQty)
        delegate?.PdQtyChange(SelectQty, indexPath: indexPath)
    }
    
    /**
     * #mark: PubPurReturnPdListCell Delegate
     * 數量選擇取消
     */
    func QtySelecteCancel() {
        
    }
    
}

