//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 進貨明細 編輯, 日期/總金額/備註
 */
class PurchaseDetailEditContainer: UITableViewController, PickerDateTimeDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!

    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var edDate: UITextField!
    @IBOutlet weak var edHTInvoId: UITextField!
    @IBOutlet weak var txtMemo: UITextView!
    @IBOutlet weak var edPriceCust: UITextField!
    @IBOutlet weak var btnCloseKB: UIButton!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public property, 上層 parent 設定
    var vcParent: PurchaseDetailEdit!
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mPicker: PickerDateTime!  // datetime Picker
    private var strCurrDate: String!  // 目前選擇的退貨日期
    private var keyboardHeight: CGFloat = 150.0  // 固定虛擬鍵盤高度
    private var currTextField: UITextField?  // 目前點取的 'UITextField'
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 初始與設定 日期時間 picker */
        // Picker data 參數
        let minDate = "201503010000"  // 最小進貨日期
        let maxDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 12)
        let defDate = pubClass.subStr(dictAllData["sdate"] as! String, strFrom: 0, strEnd: 12)
        strCurrDate = defDate
        
        mPicker = PickerDateTime.init(withUIField: edDate, withDefMaxMin: [defDate, maxDate, minDate], NavyBarTitle: pubClass.getLang("selectdate"))
        mPicker.delegate = self
        
        // textView 外觀樣式
        txtMemo.layer.cornerRadius = 5
        txtMemo.layer.borderWidth = 1
        txtMemo.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtMemo.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
        
        btnCloseKB.alpha = 0.0
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        // 设置监听键盘事件函数
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        initViewField()
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
        edHTInvoId.text = dictAllData["hte_id"] as? String
        txtMemo.text = dictAllData["memo"] as? String
        labPrice.text = dictAllData["price"] as? String
        edPriceCust.text = dictAllData["custprice"] as? String
    }
    
    /**
     * #mark: PubPurReturnPdListDelegate
     * 進貨日期選擇，本頁面 strCurrDate 重新設定
     */
    func doneSelectDateTime(strDateTime: String) {
        strCurrDate = strDateTime
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    
    /**
     * #mark: UIText 'View' Delegate
     * 虛擬鍵盤: 點取 edText 開始輸入字元
     */
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == txtMemo) {
            btnCloseKB.alpha = 1.0
        }
    }
    
    /**
     * #mark: UIText 'Field' Delegate
     * 虛擬鍵盤: 點取 edField 開始輸入字元
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        currTextField = textField
    }
    
    /**
     * #mark: PurchaseDetailEditDelegate
     * 取得 child ContainerView 頁面輸入的資料並回傳
     */
    func getContainerPageDatai1()-> Dictionary<String, AnyObject>? {
        var dictData: Dictionary<String, AnyObject> = [:]
        
        // 檢查輸入資料
        var errMsg = ""
        var strPriceCust = dictAllData["custprice"] as! String
        
        // 進貨實際金額
        errMsg = pubClass.getLang("product_purchasepricecusterr")
        if let intTmp = Int(edPriceCust.text!) {
            let strTmp = String(intTmp)
            if (strTmp.characters.count < 8) {
                strPriceCust = strTmp
                errMsg = ""
            }
        }
        
        // 顯示錯誤訊息, 回傳 nil
        if (errMsg != "") {
            pubClass.popIsee(self, Msg: errMsg)
            
            return nil
        }
        
        var strMemo = ""
        if let strTmp = txtMemo.text {
            if (strTmp.characters.count > 0) {
                strMemo = strTmp.stringByReplacingOccurrencesOfString("\n", withString: "", range: nil)
                strMemo = strMemo.stringByReplacingOccurrencesOfString("\n", withString: "", range: nil)
            }
        }
        
        // 設定回傳資料
        dictData["invo_id"] = dictAllData["id"] as! String
        dictData["custprice"] = strPriceCust
        dictData["hte_id"] = edHTInvoId.text
        dictData["memo"] = strMemo
        dictData["sdate"] = strCurrDate
        
        return dictData
    }
    
    /**
     * 關閉鍵盤
     */
    @IBAction func actCloseKB(sender: UIButton) {
        txtMemo.resignFirstResponder()
        btnCloseKB.alpha = 0.0
    }
    
    /**
     * NSNotificationCenter
     * #mark: 鍵盤: 处理弹出事件, 僅針對最底端的 editview 作用
     */
    func keyboardWillShow(notification:NSNotification) {
        if (currTextField != edPriceCust) {
            return
        }
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {

            let width = self.view.frame.width
            let height = self.view.frame.height
            let rect = CGRectMake(0.0, -(keyboardHeight), width, height)
            self.view.frame = rect
        }
    }
    
    /**
     * NSNotificationCenter
     * #mark: 鍵盤: 处理關閉事件, 僅針對最底端的 editview 作用
     */
    func keyboardWillHide(notification:NSNotification) {
        if (currTextField != edPriceCust) {
            return
        }
        currTextField = nil
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let rect = CGRectMake(0.0, 0.0, width, height)
        self.view.frame = rect
    }
}