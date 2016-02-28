//
// TableView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨明細主頁面
 */
class PurchaseListDetail: UIViewController, PurchaseListDetailCellDelegate, PubClassDelegate {
    // Delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labHteid: UILabel!
    @IBOutlet weak var labAmount: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    @IBOutlet weak var labReturnAmount: UILabel!

    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var parentVC: PurchaseList!
    
    // 其他參數設定
    private var aryPd: Array<Dictionary<String, AnyObject>>!
    private var mAlert: UIAlertController!  // alertView 功能選單
    private var keyboardHeightQty: CGFloat = 0.0  // 自訂的選擇數量鍵盤高度
    private var bolReload = false // top parent 頁面是否需要 http reload
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 進貨商品設定到 aryPd
        aryPd = dictAllData["pd"] as! Array<Dictionary<String, AnyObject>>

        // field 設定
        labHteid.text = dictAllData["hte_id"] as? String
        labAmount.text = dictAllData["price"] as? String
        labCustPrice.text = dictAllData["custprice"] as? String
        labSdate.text = pubClass.formatDateWithStr(dictAllData["sdate"] as! String, type: 14)
        
        var strReturn = ""
        if let _ = dictAllData["return"] as? Array<AnyObject> {
            strReturn = String(format: pubClass.getLang("FMT_returnmsg"), dictAllData["returnprice"] as! String, dictAllData["returnpricecust"] as! String)
        }
        labReturnAmount.text = strReturn

        // 設定彈出 ActionSheet 子選單, 提供：編輯 / 新增退貨 / 退貨明細
        setAlertVC()
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // 子頁面有資料變動，本頁面結束設定 parent class reload
        if (bolReload) {
            self.view.alpha = 0.6
            delegate?.PageNeedReload(true)
            self.dismissViewControllerAnimated(false, completion: {})
        }
        
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        // 註銷銷鍵盤監聽
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        return aryPd.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryPd.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryPd[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPurchaseListDetail", forIndexPath: indexPath) as! PurchaseListDetailCell
        
        // 取得虛擬鍵盤高度
        if (keyboardHeightQty <= 0) {
            keyboardHeightQty = mCell.kbHeight
        }
        
        mCell.delegate = self
        mCell.initView(ditItem)
        
        // 有退貨數量不能點取
        let dictPd = aryPd[indexPath.row]
        
        if (dictPd["totRQty"] as! String != "0") {
            mCell.userInteractionEnabled = false
        }
        else {
            mCell.userInteractionEnabled = true
        }
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 彈出數量選擇鍵盤
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.keyboardClose()
        
        // 有退貨數量不執行
        /*
        let dictPd = aryPd[indexPath.row]
        if (dictPd["totRQty"] as! String != "0") {
            pubClass.popIsee(self, Msg: pubClass.getLang("product_qtyreturneditto0msg"))
            return
        }
        */
        
        // 取得 cell EditField
        let edQty = (tableView.cellForRowAtIndexPath(indexPath) as! PurchaseListDetailCell).edQty
        edQty.becomeFirstResponder()
    }
    
    /**
     * #mark: PurchaseListDetailCellDelegate
     * '數量鍵盤' 點取 '完成' 回傳選擇的 qty, 執行相關程序
     */
    func QtySelecteDone(SelectQty: Int) {
        self.keyboardClose()
        
        // 彈出警告視窗，確認後執行 http 儲存，本頁面結束
        let aryMsg = [pubClass.getLang("systemwarring"), pubClass.getLang("purchase_pruchaseqtyeditmsg")]
        pubClass.popConfirm(self, aryMsg: aryMsg, withHandlerYes: {self.HTTPDataSave()}, withHandlerNo: {})
    }
    
    /**
     * 資料儲存, http 連線，完成後結束本頁面
     */
    private func HTTPDataSave() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: PurchaseListDetailCellDelegate
     * '數量鍵盤' 點取 '取消'
     */
    func QtySelecteCancel() {
        self.keyboardClose()
    }
    
    /**
     * #mark: PurchaseDetailEditDelegate Delegate
     * 設定 top parent class page 是否需要 reload
     */
    func PageNeedReload(needReload: Bool) {
        bolReload = needReload
    }
    
    /**
     * 設定 alertView 功能選單
     */
    private func setAlertVC() {
        // 彈出 ActionSheet 子選單, 提供：編輯 / 新增退貨 / 退貨明細
        mAlert = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        // 設定選單項目, 對應 ident string
        var aryIdent = ["purchase_detailedit", "purchase_returnadd"]
        if let _ = dictAllData["return"] as? Array<AnyObject> {
            aryIdent.append("purchase_returnlist")
        }
        
        // loop 子選單 ident name, 重新產生 UIAlertController
        for strIdent in aryIdent {
            mAlert.addAction(UIAlertAction(title:pubClass.getLang("product_" + strIdent), style: UIAlertActionStyle.Default, handler:{
                (alert: UIAlertAction!)->Void in
                
                // 執行 'prepareForSegue' 跳轉指定頁面
                self.performSegueWithIdentifier(strIdent, sender: nil)
            }))
        }
        
        mAlert.addAction(UIAlertAction(title: pubClass.getLang("cancel"), style: UIAlertActionStyle.Destructive, handler:nil))
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 編輯
        if (strIdent == "purchase_detailedit") {
            let mVC = segue.destinationViewController as! PurchaseDetailEdit
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
        
        // 新增退貨
        if (strIdent == "purchase_returnadd") {
            let mVC = segue.destinationViewController as! PurchaseReturnAdd
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
        
        // 退貨明細
        if (strIdent == "purchase_returnlist") {
            let mVC = segue.destinationViewController as! PurchaseReturnList
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            
            return
        }
    }
    
    /**
     * act, 點取 '功能' button
     */
    @IBAction func actOption(sender: UIBarButtonItem) {
        self.presentViewController(mAlert, animated: true, completion: nil)
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    /**
     * 關閉鍵盤, View 設定回原位置
     */
    private func keyboardClose() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        let rect = CGRectMake(0.0, 0.0, width, height)
        self.view.frame = rect
    }
    
    /**
     * NSNotificationCenter
     * #mark: 鍵盤: 处理弹出事件
     */
    func keyboardWillShow(notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            var mPoint = keyboardSize.height - 44.0
            if (keyboardHeightQty == keyboardSize.height) {
                mPoint -= 45
            }
            
            let width = self.view.frame.width
            let height = self.view.frame.height
            let rect = CGRectMake(0.0, -(mPoint), width, height)
            self.view.frame = rect
        }
    }
    
}