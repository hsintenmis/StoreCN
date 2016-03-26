//
// TableView
//

import UIKit
import Foundation

/**
 * 會員購貨紀錄明細主頁面，由會員管理購貨紀錄轉入
 * 提供退貨新增/修改，金額，數量修改等功能
 */
class SaleDetail: UIViewController, SaleDetailCellDelegate {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labHteid: UILabel!
    @IBOutlet weak var labAmount: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    @IBOutlet weak var labReturnAmount: UILabel!
    @IBOutlet weak var labMemberName: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var aryPd: Array<Dictionary<String, AnyObject>>!  // 出貨商品 array
    private var mAlert: UIAlertController!  // alertView 功能選單 (ActionSheet menu)
    private var keyboardHeightQty: CGFloat = 0.0  // 自訂的選擇數量鍵盤高度
    private var bolReload = false // parent 頁面是否需要 http reload
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 出貨商品設定到 aryPd
        aryPd = dictAllData["odrs"] as! Array<Dictionary<String, AnyObject>>
        
        // field 設定
        labHteid.text = dictAllData["id"] as? String
        labAmount.text = dictAllData["price"] as? String
        labCustPrice.text = dictAllData["custprice"] as? String
        labSdate.text = pubClass.formatDateWithStr(dictAllData["sdate"] as! String, type: 14)
        labMemberName.text = dictAllData["membername"] as? String
        
        //  退貨文字處理
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
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PurchaseListDetail.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        // 註銷銷鍵盤監聽
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     * 設定 ActionSheet 功能選單
     */
    private func setAlertVC() {
        // 彈出 ActionSheet 子選單, 提供：編輯 / 新增退貨 / 退貨明細
        mAlert = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        // 設定選單項目, 對應 ident string
        var aryIdent = ["sale_detailedit", "sale_returnadd"]
        if let _ = dictAllData["return"] as? Array<AnyObject> {
            aryIdent.append("sale_returnlist")
        }
        
        // loop 子選單 ident name, 重新產生 UIAlertController
        for strIdent in aryIdent {
            mAlert.addAction(UIAlertAction(title:pubClass.getLang("sale_" + strIdent), style: UIAlertActionStyle.Default, handler:{
                (alert: UIAlertAction!)->Void in
                
                // 執行 'prepareForSegue' 跳轉指定頁面
                self.performSegueWithIdentifier(strIdent, sender: nil)
            }))
        }
        
        mAlert.addAction(UIAlertAction(title: pubClass.getLang("cancel"), style: UIAlertActionStyle.Destructive, handler:nil))
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSaleDetail", forIndexPath: indexPath) as! SaleDetailCell
        
        // 取得虛擬鍵盤高度
        if (keyboardHeightQty <= 0) {
            keyboardHeightQty = mCell.kbHeight
        }
        
        mCell.delegate = self
        mCell.initView(ditItem, indexpath: indexPath)
        
        // 有退貨數量不能點取
        if (Int(ditItem["returnQty"] as! String) > 0) {
            mCell.userInteractionEnabled = false
        } else {
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
        
        // 取得 cell EditField
        let edQty = (tableView.cellForRowAtIndexPath(indexPath) as! SaleDetailCell).edQty
        edQty.becomeFirstResponder()
    }
    
    /**
     * #mark: SaleDetailCellDelegate
     * 出貨商品數量 '數量鍵盤'點取完成，回傳選擇的 qty, 執行相關程序
     */
    func QtySelecteDone(SelectQty: Int, indexpath: NSIndexPath) {
        self.keyboardClose()

        // HTTP 連線參數設定
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "sale"
        dictParm["act"] = "sale_qtysave"
        
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["pdid"] = aryPd[indexpath.row]["pdid"] as! String
        dictArg0["qty"] = String(SelectQty)
        dictArg0["invo_id"] = dictAllData["id"] as? String
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // 彈出警告視窗，確認後執行 http 儲存，本頁面結束
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("sale_pruchaseqtyeditmsg")], withHandlerYes: {self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack:{ (dictRS: Dictionary<String, AnyObject>) -> Void in
            
            // 回傳後跳離
            var strMsg = self.pubClass.getLang("err_trylatermsg")
            let bolRS = dictRS["result"] as! Bool
            if (bolRS == true) {
                strMsg = self.pubClass.getLang("datasavecompleted")
            }
            
            self.pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {
                // 通知 parent 資料有變動
                self.delegate?.PageNeedReload!(bolRS)
            })})
            
            return
            
        } )}, withHandlerNo: {return})
    }
    
    /**
     * #mark: PurchaseListDetailCellDelegate
     * '數量鍵盤' 點取 '取消'
     */
    func QtySelecteCancel() {
        self.keyboardClose()
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
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        let strIdent = segue.identifier
        
        // 編輯
        if (strIdent == "sale_detailedit") {
            let mVC = segue.destinationViewController as! PurchaseDetailEdit
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
        
        // 新增退貨
        if (strIdent == "sale_returnadd") {
            let mVC = segue.destinationViewController as! PurchaseReturnAdd
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
        
        // 退貨明細
        if (strIdent == "sale_returnlist") {
            let mVC = segue.destinationViewController as! PurchaseReturnList
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
        */
        
        return
    }
    
    /**
     * act, 點取 '選項' button
     */
    @IBAction func actOption(sender: UIBarButtonItem) {
        self.presentViewController(mAlert, animated: true, completion: nil)
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
}