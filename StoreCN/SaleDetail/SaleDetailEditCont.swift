//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 *  出貨明細編輯主頁面, 日期/總金額/備註
 */
class SaleDetailEditCont: UITableViewController, UITextFieldDelegate, UITextViewDelegate, PickerDateTimeDelegate {
    
    // @IBOutlet
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var edDate: UITextField!
    @IBOutlet weak var txtMemo: UITextView!
    @IBOutlet weak var edPriceCust: UITextField!
    @IBOutlet weak var btnCloseKB: UIButton!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public property, parent 設定
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var mPicker: PickerDateTime!  // datetime Picker
    private var strCurrDate: String!  // 目前選擇的出貨日期
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 初始與設定 日期時間 picker */
        // Picker data 參數
        let minDate = "201503010000"  // 最小出貨日期
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
        initViewField()
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
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
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 點取 edText 開始輸入字元
     */
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == txtMemo) {
            btnCloseKB.alpha = 1.0
        }
    }
    
    /**
     * public, parent 調用，回傳本頁面編輯資料
     */
    func getPageData()-> Dictionary<String, AnyObject>? {
        var dictData: Dictionary<String, AnyObject> = [:]
        
        // 檢查輸入資料
        var errMsg = ""
        var strPriceCust = dictAllData["custprice"] as! String
        
        // 進貨實際金額
        errMsg = pubClass.getLang("sale_pricecusterr")
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
        dictData["invo_id"] = self.dictAllData["id"] as! String
        dictData["custprice"] = strPriceCust
        dictData["memo"] = strMemo
        dictData["sdate"] = self.strCurrDate
        
        return dictData
    }
    
    /**
     * 關閉鍵盤
     */
    @IBAction func actCloseKB(sender: UIButton) {
        txtMemo.resignFirstResponder()
        btnCloseKB.alpha = 0.0
    }
    
}