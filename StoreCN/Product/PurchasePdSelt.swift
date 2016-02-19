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
    @IBOutlet weak var edQty: UITextField!  // 虛擬的輸入框
    
    // common property
    let pubClass: PubClass = PubClass()
    var mPickerQty: PickerQty!
    
    // public, 從 parent 設定
    var strToday = ""
    var dictCategoryPd: Dictionary<String, Array<Dictionary<String, String>>> = [:] // 已經分類完成的商品
    
    // 其他 property
    private var tableW: CGFloat = 0.0
    private var tableH: CGFloat = 0.0

    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        // 固定初始參數
        edQty.alpha = 0.0
        
        //tableData.layer.frame.size.height
        
        mPickerQty = PickerQty(edView: edQty, DefVal: 5, MinMaxAry: [0, 99], NavyBarTitle: pubClass.getLang("peoduct_selectqty"))
        
        mPickerQty.delegate = self
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if (self.tableW <= 0.0) {
                self.tableW = self.tableData.frame.size.width
                self.tableH = self.tableData.frame.size.height
            }
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
        
        edQty.becomeFirstResponder()
        
        mPickerQty.ShowQtyView(DefaultVal: Int(dictPd["qtySel"]!)!, tableIndexPath: indexPath)
    }
    
    /**
     * #mark: PickerQtyDelegate
     * '數量鍵盤' 點取 '完成' 回傳選擇的 qty
     */
    func QtySelecteDone(SelectQty: Int) {
        QtySelecteCancel()
        
        print(SelectQty)
    }
    
    /**
     * #mark: PickerQtyDelegate
     * '數量鍵盤' 點取 '取消'
     */
    func QtySelecteCancel() {
        edQty.resignFirstResponder()
        let rect = CGRectMake(0.0, 0.0, tableW, tableH);
        
        tableData.frame = rect
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     * act, 點取 '完成' button
     */
    @IBAction func actDone(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {
            self.delegate?.PdSeltPageDone(PdAllData: self.dictCategoryPd)
        })
    }
    
    /**
     * NSNotificationCenter
     * #mark: 鍵盤: 处理弹出事件
     */
    func keyboardWillShow(notification:NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {

            let rect = CGRectMake(0.0, -210.0, tableW, tableH)
            
            /*
            let heightPKView = mPKView.frame.size.height
            let tableHight = mParentTableView.contentSize.height
            mParentTableView.contentSize.height = tableHight - heightPKView
            */
            
            /*
            let offset = CGPointMake(0,
            (mParentTableView.contentSize.height - mParentTableView.frame.size.height))
            mParentTableView.setContentOffset(offset, animated: true)
            */
            
            /*
            mParentTableView.reloadData()
            mParentTableView.selectRowAtIndexPath(currIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            */
            
            tableData.frame = rect
        }
    }

    
}

