//
// 商品數量選擇 page class and Delegate, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 商品管理選單, 銷貨
 */
class Sale: UIViewController, SalePdSeltDelegate, SalePdSeltCellDelegate, PdSaleMemberSelDelegate, UITextFieldDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labTotPrice: UILabel!
    @IBOutlet weak var edRealPrice: UITextField!
    @IBOutlet weak var edMemo: UITextField!
    @IBOutlet weak var labMemberName: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 從 parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 商品資料設定
    private var aryPdType: Array<String>! // 商品分類
    private var dictCategoryPd: Dictionary<String, Array<Dictionary<String, String>>> = [:] // 已經分類完成的商品
    private var aryCart: Array<Dictionary<String, String>> = []
    
    // 其他 property
    private var aryMember: Array<Dictionary<String, AnyObject>> = [] // 會員 array data
    private var indexPathMember: NSIndexPath?  // 以選擇的會員 indexpath
    
    private var keyboardHeightQty: CGFloat = 0.0  // 自訂的選擇數量鍵盤高度
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        aryPdType = pubClass.aryProductType
        
        // 檢查資料
        var strErr = ""
        if let _ = dictAllData["pd"] as? Array<Dictionary<String, AnyObject>> {
            // 重設商品分類 array data
            initAllPd()
        } else {
            strErr = pubClass.getLang("product_nodatapurchasefirst")
        }
        
        if let tmpMember = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpMember
        } else {
            strErr = pubClass.getLang("member_nodataaddfirst")
        }
        
        if (strErr != "") {
            pubClass.popIsee(self, Msg: strErr, withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Sale.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }

    /**
     * View DidAppear 程序
     */
    override func viewWillDisappear(animated: Bool) {
        // 註銷銷鍵盤監聽
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     * 重設商品分類 array data
     */
    private func initAllPd() {
        dictCategoryPd = [:]
        let aryAllPd = dictAllData["pd"] as! Array<Dictionary<String, String>>
        
        var aryPd_S: Array<Dictionary<String, String>> = []
        var aryPd_C: Array<Dictionary<String, String>> = []
        var aryPd_N: Array<Dictionary<String, String>> = []
        var dictNewPd: Dictionary<String, String>
        
        for dictPd in aryAllPd {
            let strType: String! = dictPd["ptype"]
            dictNewPd = dictPd
            
            // 新增欄位, qtySel, qtyOrg
            dictNewPd["qtySel"] = "0"
            dictNewPd["qtyOrg"] = "0"
            
            if (strType == "S") {
                aryPd_S.append(dictNewPd)
            } else if(strType == "C") {
                aryPd_C.append(dictNewPd)
            } else {
                aryPd_N.append(dictNewPd)
            }
        }
        
        dictCategoryPd["S"] = aryPd_S
        dictCategoryPd["C"] = aryPd_C
        dictCategoryPd["N"] = aryPd_N
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        
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
        return aryCart.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryCart.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryCart[indexPath.row] as Dictionary<String, String>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellSalePdSeltCart", forIndexPath: indexPath) as! SalePdSeltCell
        
        // 取得虛擬鍵盤高度
        if (keyboardHeightQty <= 0) {
            keyboardHeightQty = mCell.kbHeight
        }
        
        mCell.delegate = self
        mCell.initView(ditItem)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 彈出數量選擇鍵盤
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
        self.keyboardClose()
        
        // 取得點取商品的 dict data
        let dictPd = aryCart[currIndexPath!.row]
        let strPType = dictPd["ptype"]!
        let position = Int(dictPd["position"]!)
        
        // 更新 'dictCategoryPd' 指定商品數量
        dictCategoryPd[strPType]![position!]["qtySel"] = String(SelectQty)
        
        // 重新產生 cartPD array data, 計算選擇商品的金額加總
        resetCartData()
        tableData.reloadData()
        
        if (SelectQty != 0) {
            tableData.selectRowAtIndexPath(currIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
        }
    }
    
    /**
     * #mark: SalePdSeltCellDelegate
     * '數量鍵盤' 點取 '取消'
     */
    func QtySelecteCancel() {
        self.keyboardClose()
    }
    
    /**
     * #mark: SalePdSeltDelegate
     * 商品選擇頁面，點取'完成'
     */
    func PdSeltPageDone(PdAllData: Dictionary<String, Array<Dictionary<String, String>>>) {
        
        // 重新產生 '購物車' list array
        dictCategoryPd = PdAllData
        resetCartData()
        
        tableData.reloadData()
    }
    
    /**
     * 重新產生 cartPD array data, 計算選擇商品的金額加總
     */
    private func resetCartData() {
        var intAmount = 0
        aryCart = []
        
        for strPType in aryPdType {
            let aryPd = dictCategoryPd[strPType]!
            
            for i in (0..<aryPd.count) {
                var dictPd = aryPd[i]
                let intQty = Int(dictPd["qtySel"]!)
                
                if (intQty > 0) {
                    intAmount += intQty! * Int(dictPd["price"]!)!
                    
                    // dictPd 加到 aryCart
                    dictPd["position"] = String(i)
                    dictPd["oqty"] = dictPd["qtySel"]  //  server 存擋欄位

                    aryCart.append(dictPd)
                }
            }
        }
        
        labTotPrice.text = String(intAmount)
        edRealPrice.text = String(intAmount)
    }
    
    /**
     * #mark: PdSaleMemberSelDelegate
     * 會員選擇頁面，點取'會員 Item'
     */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        indexPathMember = MemberindexPath
        labMemberName.text = MemberData["membername"] as? String
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 商品選擇頁面
        if (strIdent == "SalePdSelt") {
            let mVC = segue.destinationViewController as! SalePdSelt
            mVC.delegate = self
            mVC.strToday = strToday
            mVC.dictCategoryPd = sender as! Dictionary<String, Array<Dictionary<String, String>>>
            
            return
        }
        
        // 會員選擇頁面
        if (strIdent == "PdSaleMemberSel") {
            let mVC = segue.destinationViewController as! PdSaleMemberSel
            mVC.delegate = self
            mVC.strToday = strToday
            mVC.currIndexPath = indexPathMember
            mVC.aryMember = sender as! Array<Dictionary<String, AnyObject>>
            
            return
        }
    }
    
    /**
     * act, 點取 '清空商品' button
     */
    @IBAction func actEmpty(sender: UIButton) {
        initAllPd()
        resetCartData()
        tableData.reloadData()
    }
    
    /**
     * act, 點取 '選擇商品' button, 跳轉'選擇商品'頁面
     */
    @IBAction func actPdSelt(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("SalePdSelt", sender: dictCategoryPd)
    }
    
    /**
     * act, 點取 '選擇會員 button, 跳轉'選擇會員'頁面
     */
    @IBAction func actMemberSelt(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("PdSaleMemberSel", sender: aryMember)
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 是否有選擇會員
        if (indexPathMember == nil) {
            pubClass.popIsee(self, Msg: pubClass.getLang("product_saleselmembermsg"))
            return
        }
        
        // 檢查是否有商品
        if (aryCart.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("product_selpdfirstmsg"))
            return
        }
        
        // 檢查實際金額
        if let intTmp = Int(edRealPrice.text!) {
            let strTmp = String(intTmp)
            if (strTmp.characters.count > 8) {
                pubClass.popIsee(self, Msg: pubClass.getLang("product_salerealpriceerr"))
                return
            }
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("product_salerealpriceerr"))
            return
        }
        
        // 確認視窗，執行 http 連線資料儲存
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("sysprompt"), pubClass.getLang("datasendplzconfirmmsg")], withHandlerYes: { self.saveData() }, withHandlerNo: {})
        
        return
    }
    
    /**
     * http 連線資料儲存
     */
    private func saveData() {
        // 設定 'arg0' dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        var dictMemo: Dictionary<String, String> = [:]
        dictMemo["price"] = labTotPrice.text
        dictMemo["custprice"] = edRealPrice.text
        dictMemo["memo"] = edMemo.text
        
        dictArg0["memo"] = dictMemo
        dictArg0["cart"] = aryCart
        dictArg0["member"] = aryMember[indexPathMember!.row]
        
        // 產生 http post data, http 連線儲存後跳離
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "sale"
        dictParm["act"] = "sale_senddata"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 連線後取得連線結果
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictRS: Dictionary<String, AnyObject>) -> Void in
            let bolsRS = dictRS["result"] as! Bool
            let strMsg = (bolsRS != true) ? self.pubClass.getLang("err_trylatermsg") : self.pubClass.getLang("datasavecompleted")
            
            // 清除商品資料
            self.initAllPd()
            self.resetCartData()
            self.tableData.reloadData()
            self.edMemo.text = ""
            
            self.pubClass.popIsee(self, Msg: strMsg)
        })
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 實際金額檢查
        if textField == edRealPrice {
            edRealPrice.resignFirstResponder()
            
            if let tmpPrice = Int(edRealPrice.text!) {
                // 數入字元數檢查，8位數
                if ( String(tmpPrice).characters.count > 8 ) {
                    edRealPrice.text = labTotPrice.text
                    pubClass.popIsee(self, Msg: pubClass.getLang("pricemaxovermsg"))
                }
            } else {
                edRealPrice.text = labTotPrice.text
            }
            
        }
        else if textField == edMemo {
            edMemo.resignFirstResponder()
        }
        
        // 關閉鍵盤, View 設定回原位置
        keyboardClose()
        
        return true
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
                mPoint -= 115
            }
            
            let width = self.view.frame.width
            let height = self.view.frame.height
            let rect = CGRectMake(0.0, -(mPoint), width, height)
            self.view.frame = rect
        }
    }
    
}

