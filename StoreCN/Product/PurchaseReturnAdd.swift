//
// TableView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨退回，新增一筆退貨單資料
 */
class PurchaseReturnAdd: UIViewController, PubPurReturnPdListDelegate {
    // Delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labHteid: UILabel!
    @IBOutlet weak var labAmount: UILabel!
    @IBOutlet weak var edRDate: UITextField!
    @IBOutlet weak var edCustPrice: UITextField!
    
    @IBOutlet weak var containView: UIView!

    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數
    private var aryReturnPd: Array<Dictionary<String, AnyObject>>!  // 退貨商品 array
    
    // UIDatePicker 設定
    private var defDate:String!
    private var maxDate: String!
    private var minDate: String!
    private var datePickerView: UIDatePicker!
    
    // 根據local顯示可閱讀的日期, ex. 2015年1月1日 13:59
    private let dateFmtYMD: NSDateFormatter = NSDateFormatter()
    private var strCurrDate: String!  // 取得目前選擇的日期，轉為 12碼 string
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定退貨商品 array data, 加入數量相關欄位
        aryReturnPd = dictAllData["pd"] as! Array<Dictionary<String, AnyObject>>
        for (var i=0; i < aryReturnPd.count; i++) {
            aryReturnPd[i]["selQty"] = "0"
        }
        
        // Picker data 參數
        datePickerView = UIDatePicker()
        minDate = pubClass.subStr(dictAllData["sdate"] as! String, strFrom: 0, strEnd: 10) + "59"
        maxDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 8) + "2359"
        defDate = maxDate
        strCurrDate = defDate
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
     * View WillAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // 初始公用 class 退貨商品列表 'PubPurReturnPdList'
        let mPubPurReturnPdList = storyboard!.instantiateViewControllerWithIdentifier("PubPurReturnPdList") as! PubPurReturnPdList
        
        mPubPurReturnPdList.delegate = self
        mPubPurReturnPdList.aryData = aryReturnPd
        mPubPurReturnPdList.strToday = strToday
        
        // ContainerView 加入 vc 'PubPurReturnPdList'
        let mView = mPubPurReturnPdList.view
        mView.frame.size.height = containView.layer.frame.height
        self.containView.addSubview(mView)
        self.navigationController?.pushViewController(mPubPurReturnPdList, animated: true)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        // field value 設定
        labSdate.text = pubClass.formatDateWithStr(dictAllData["sdate"] as! String, type: 14)
        labHteid.text = dictAllData["hte_id"] as? String
        edRDate.text = pubClass.formatDateWithStr(strToday, type: 14)
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
        edRDate.inputView = datePickerView
        self.initKBBar(pubClass.getLang("product_selreturndate"))
        
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
        
        edRDate.inputAccessoryView = toolBar
    }

    /**
     * DatePicker 點取　'done', 欄位值改變, @objc 注意用法
     */
    @objc private func PKDateDone() {
        edRDate.resignFirstResponder()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.edRDate.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
        
        // 設定 strDate value
        strCurrDate = dateFmtYMD.stringFromDate(self.datePickerView.date)
    }
    
    /**
     * DatePicker 點取　'cancel'
     */
    func PKDateCancel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.edRDate.text = self.pubClass.formatDateWithStr(self.strCurrDate, type: 14)
        })
        
        edRDate.resignFirstResponder()
    }
    
    /**
     * DatePicker Value change
     */
    @objc private func datePickerValueChanged(sender:UIDatePicker) {
        dispatch_async(dispatch_get_main_queue(), {
            self.edRDate.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
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
     * #mark: PubPurReturnPdListDelegate
     * 退貨商品數量改變，本頁面相關資料變動
     */
    func PdQtyChange(SelectQty: Int, indexPath: NSIndexPath) {
        // aryReturnPd 設定 selQty
        aryReturnPd[indexPath.row]["selQty"] = String(SelectQty)
        
        // 退貨總金額處理
        var intTot = 0
        for dictPd in aryReturnPd {
            intTot += Int(dictPd["price"] as! String)! * Int(dictPd["selQty"] as! String)!
        }

        labAmount.text = String(intTot)
        edCustPrice.text = String(intTot)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let strIdent = segue.identifier
        
    }
    
    /**
     * act, 點取 '確定退貨' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        // 檢查是否有退貨, 重新產生傳送的退貨商品 array
        var aryRPd: Array<Dictionary<String, AnyObject>> = []
        
        for var dictPd in aryReturnPd {
            let qty = Int(dictPd["selQty"] as! String)!
            if (qty > 0) {
                dictPd["rqty"] = dictPd["selQty"] as! String
                aryRPd.append(dictPd)
            }
        }
        
        if (aryRPd.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("purchase_noreturnpdselmsg"))
            
            return
        }
        
        // 檢查實際退貨金額
        if let intTmp = Int(edCustPrice.text!) {
            let strTmp = String(intTmp)
            if (strTmp.characters.count <= 8) {
                edCustPrice.text = strTmp
            }
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("product_returnpricecusterr"))
            
            return
        }
        
        // 產生 http post data, http 連線儲存後跳離
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "purchase"
        dictParm["act"] = "purchase_returnaddsave"
        
        var dictArg0: Dictionary<String, AnyObject> = [:]
        dictArg0["invo_id"] = dictAllData["id"] as? String
        dictArg0["custprice"] = edCustPrice.text!
        dictArg0["sdate"] = strCurrDate
        dictArg0["pd"] = aryRPd
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 開始連線
        pubClass.popConfirm(self, aryMsg: ["", pubClass.getLang("purchase_mksurepurchasereturnmsg")], withHandlerYes: {self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: self.HttpSaveResponChk)}, withHandlerNo: {return})
    }

    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 回傳後跳離, 通知 parent 資料 reload
        let strMsg = (dictRS["result"] as! Bool != true) ? pubClass.getLang("err_trylatermsg") : pubClass.getLang("datasavecompleted")
        
        delegate?.PageNeedReload(true)
        pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}