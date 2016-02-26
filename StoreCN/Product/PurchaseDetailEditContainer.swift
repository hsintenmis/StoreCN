//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 進貨明細 編輯, 日期/總金額/備註
 */
class PurchaseDetailEditContainer: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
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
    
    // 日期預設值，最大/最小

    
    // UIDatePicker 設定
    private var defDate:String!
    private var maxDate: String!
    private var minDate = "201503010000"
    private var datePickerView: UIDatePicker!
    
    // 根據local顯示可閱讀的日期, ex. 2015年1月1日 13:59
    private let dateFmtYMD: NSDateFormatter = NSDateFormatter()
    private var strCurrDate: String!  // 取得目前選擇的日期，轉為 12碼 string
    
    // 其他參數

    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Picker data 參數
        datePickerView = UIDatePicker()
        maxDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 8) + "2359"
        defDate = pubClass.subStr(dictAllData["sdate"] as! String, strFrom: 0, strEnd: 12)
        strCurrDate = defDate
        
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
        initDatePicker()
        initViewField()
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        edDate.text = self.pubClass.formatDateWithStr(defDate, type: 14)
        edHTInvoId.text = dictAllData["hte_id"] as? String
        txtMemo.text = dictAllData["memo"] as? String
        labPrice.text = dictAllData["price"] as? String
        edPriceCust.text = dictAllData["custprice"] as? String
    }
    
    /**
     * UIDatePicker 初始設定
     * "dd-MM-yyyy HH:mm:ss"
     */
    private func initDatePicker() {
        // 設定日期顯示樣式
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        dateFmtYMD.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFmtYMD.timeStyle = NSDateFormatterStyle.MediumStyle
        
        dateFmtYMD.dateFormat = "yyyyMMddHHmm"
        //dateFmtYMD.timeZone = NSTimeZone(abbreviation: "UTC");
        
        datePickerView.minimumDate = dateFmtYMD.dateFromString(minDate)!
        datePickerView.maximumDate = dateFmtYMD.dateFromString(maxDate)!
        
        // 設定 datePick value change 要執行的程序
        //datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        // 設定預設值
        let mDate = dateFmtYMD.dateFromString(defDate)!
        datePickerView.setDate(mDate, animated: false)
        

        // 設定 edDate 輸入鍵盤，樣式
        edDate.inputView = datePickerView
        self.initKBBar(pubClass.getLang("product_selpurchasedate"))
     
        // 設定 datePicker value change
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /**
     * 鍵盤輸入視窗的 'navybar' 設定
     * 日期欄位 點取彈出 資料輸入視窗 (虛擬鍵盤), 'InputView' 的頂端顯示 'navyBar'
     */
    private func initKBBar(strTitle: String) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true  // 半透明
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)  // 文字顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("select_ok"), style: UIBarButtonItemStyle.Plain, target: self, action: "PKDateDone")
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // 自訂一個 label 作為 NavyBar 的 Title
        let labTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 14.0))
        labTitle.text = strTitle
        //labTitle.font = UIFont(name: "System", size: 14)
        labTitle.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: labTitle)
        
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "PKDateCancel")
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        edDate.inputAccessoryView = toolBar
    }
    
    /**
     * DatePicker 點取　'done', 欄位值改變, @objc 注意用法
     */
    @objc private func PKDateDone() {
        edDate.resignFirstResponder()

        dispatch_async(dispatch_get_main_queue(), {
            self.edDate.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
        
        // 設定 strDate value
        strCurrDate = dateFmtYMD.stringFromDate(self.datePickerView.date)
    }
    
    /**
     * DatePicker 點取　'cancel'
     */
    func PKDateCancel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.edDate.text = self.pubClass.formatDateWithStr(self.strCurrDate, type: 14)
        })
        
        edDate.resignFirstResponder()
    }
    
    /**
     * DatePicker Value change
     */
    @objc private func datePickerValueChanged(sender:UIDatePicker) {
        dispatch_async(dispatch_get_main_queue(), {
            self.edDate.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
    }

    
    /**
     * 編輯模式特殊處理
     */
    private func procEditMode() {
        
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
     * #mark: PurchaseDetailEditDelegate
     * 取得 child ContainerView 頁面輸入的資料並回傳
     */
    func getContainerPageData1() -> Dictionary<String, AnyObject>? {
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
}
