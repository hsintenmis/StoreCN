//
// TableView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨退回，新增一筆退貨單資料
 */
class PurchaseReturnAdd: UIViewController, PubPurReturnPdListDelegate, PickerDateTimeDelegate {
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
    private var mPicker: PickerDateTime!  // datetime Picker
    private var strCurrDate: String!  // 目前選擇的退貨日期
    
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
        
        /* 初始與設定 日期時間 picker */
        // Picker data 參數
        let minDate = pubClass.subStr(dictAllData["sdate"] as! String, strFrom: 0, strEnd: 10) + "59"
        let maxDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 10) + "59"
        let defDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 12)
        strCurrDate = defDate
        
        mPicker = PickerDateTime.init(withUIField: edRDate, withDefMaxMin: [defDate, maxDate, minDate], NavyBarTitle: pubClass.getLang("selectdate"))
        mPicker.delegate = self
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        initViewField()
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
     * #mark: PubPurReturnPdListDelegate
     * 退貨日期選擇，本頁面 strCurrDate 重新設定
     */
    func doneSelectDateTime(strDateTime: String) {
        strCurrDate = strDateTime
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
        
        delegate?.PageNeedReload!(true)
        pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}