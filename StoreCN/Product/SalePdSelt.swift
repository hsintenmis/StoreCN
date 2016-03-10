//
// TableView
//

import UIKit
import Foundation

/**
 * protocol, SalePdSelt Delegate
 */
protocol SalePdSeltDelegate {
    /**
     * 本頁面點取'完成'btn, 回傳已變動的全部商品 array data
     */
    func PdSeltPageDone(PdAllData: Dictionary<String, Array<Dictionary<String, String>>>)
}

/**
 * 商品選擇，從 [商品銷售] 頁面轉入
 */
class SalePdSelt: UIViewController, SalePdSeltCellDelegate {
    // protocol delegate
    var delegate = SalePdSeltDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labAmount: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 從 parent 設定
    var strToday = ""
    var dictCategoryPd: Dictionary<String, Array<Dictionary<String, String>>> = [:] // 已經分類完成的商品
    
    // 其他 property
    private var aryPdType: Array<String>! // 商品分類
    private var keyboardHeight: CGFloat = 0.0
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aryPdType = pubClass.aryProductType
        
        // 計算總金額
        labAmount.text = String(self.calTotAmount())
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        // 註銷鍵盤監聽
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        return pubClass.getLang("product_ptype_" + aryPdType[section])
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSalePdSelt", forIndexPath: indexPath) as! SalePdSeltCell
        
        // 取得虛擬鍵盤高度
        if (keyboardHeight <= 0) {
            keyboardHeight = mCell.kbHeight
        }
        
        mCell.delegate = self
        mCell.initView(ditItem)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        
        // 取得 cell EditField
        let edQty = (tableView.cellForRowAtIndexPath(indexPath) as! SalePdSeltCell).edQty
        edQty.becomeFirstResponder()
    }
    
    /**
     * #mark: SalePdSeltCellDelegate
     * '數量鍵盤' 點取 '完成' 回傳選擇的 qty, 執行相關程序
     */
    func QtySelecteDone(SelectQty: Int) {
        QtySelecteCancel()
        
        // 設定 'dictCategoryPd' 指定商品的 '選擇數量'
        let strPType = aryPdType[currIndexPath!.section]
        let position = currIndexPath!.row
        dictCategoryPd[strPType]![position]["qtySel"] = String(SelectQty)
        
        // Cell 相關欄位資料更新
        let ditItem = dictCategoryPd[strPType]![position] as Dictionary<String, AnyObject>
        let intPrice = Int(ditItem["price"] as! String)!
        let intQty = Int(ditItem["qtySel"] as! String)!
        let totPrice = intPrice * intQty
        
        let mCell = tableData.cellForRowAtIndexPath(currIndexPath!) as! SalePdSeltCell
        
        mCell.labQty.text = String(intQty)
        mCell.labTot.text = String(totPrice)
        
        // 顏色,樣式 相關設定
        let mColor =  (Int(ditItem["qtySel"] as! String) > 0) ? pubClass.ColorHEX(pubClass.dictColor["BlueDark"]!) : pubClass.ColorHEX(pubClass.dictColor["gray"]!)
        mCell.labQty.textColor = mColor
        mCell.labTot.textColor = mColor
        
        // 總金額修改
        labAmount.text = String(self.calTotAmount())
    }
    
    /**
     * #mark: SalePdSeltCellDelegate
     * '數量鍵盤' 點取 '取消'
     */
    func QtySelecteCancel() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        let rect = CGRectMake(0.0, 0.0, width, height)
        self.view.frame = rect
    }
    
    /**
     * 計算選擇商品的金額加總
     */
    private func calTotAmount() -> Int {
        var intAmount = 0
        for strPType in aryPdType {
            let aryPd = dictCategoryPd[strPType]!
            for dictPd in aryPd {
                let intQty = Int(dictPd["qtySel"]!)
                if (intQty > 0) {
                    intAmount += intQty! * Int(dictPd["price"]!)!
                }
            }
        }
        
        return intAmount
    }
    
    /**
     * act, 點取 '商品分類' UISegmentedControl
     */
    @IBAction func actPdType(sender: UISegmentedControl) {
        let mIndexPath = NSIndexPath(forRow: 0, inSection: sender.selectedSegmentIndex)
        tableData.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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
            self.delegate?.PdSeltPageDone(self.dictCategoryPd)
        })
    }
    
    /**
     * NSNotificationCenter
     * #mark: 鍵盤: 处理弹出事件
     */
    func keyboardWillShow(notification:NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            //print("PdSelt: \(keyboardSize.height)")
            
            let width = self.view.frame.width
            let height = self.view.frame.height
            let rect = CGRectMake(0.0, -(keyboardHeight), width, height)
            self.view.frame = rect
        }
    }
    
    
}

