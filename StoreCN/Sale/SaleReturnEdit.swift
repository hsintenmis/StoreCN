//
// with ContainerView, 調用公用 class 'PubPurReturnPdList'
//

import UIKit
import Foundation

/**
 * 商品管理 - 銷貨退回，編輯退貨項目與相關資料
 */
class SaleReturnEdit: UIViewController, SaleReturnPdListDelegate , PickerDateTimeDelegate {
    // Delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var labAmount: UILabel!
    @IBOutlet weak var edRDate: UITextField!
    @IBOutlet weak var edCustPrice: UITextField!
    @IBOutlet weak var swchDelAll: UISwitch!
    @IBOutlet weak var btnDelAll: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @IBOutlet weak var containView: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    var dictReturn: Dictionary<String, AnyObject>!  // 退貨單資料
    var dictPurchasePd: Dictionary<String, AnyObject>!  // 銷貨商品資料
    var purchaseDate: String!  // 銷貨日期
    
    // 其他參數
    private var aryReturnPd: Array<Dictionary<String, AnyObject>>!  // 退貨商品 array
    private var mPicker: PickerDateTime!  // datetime Picker
    private var strCurrDate: String!  // 目前選擇的退貨日期
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // field 設定
        btnDelAll.alpha = 0.0
        labAmount.text = dictReturn["price"] as? String
        edCustPrice.text = dictReturn["custprice"] as? String
    }
    
    /**
     * init view param 相關參數
     */
    private func initParm() {
        // 設定退貨商品 array data, 加入數量相關欄位
        aryReturnPd = dictReturn["pd"] as! Array<Dictionary<String, AnyObject>>
        
        for i in (0..<aryReturnPd.count) {
            //for (var i=0; i < aryReturnPd.count; i++) {
            let pdid = aryReturnPd[i]["pdid"] as! String
            let dictPd = dictPurchasePd[pdid]!
            
            var intMax = Int(dictPd["maxqty"] as! String)!
            let intSel = Int(aryReturnPd[i]["qty"] as! String)!
            let intReturn = Int(dictPd["totRQty"] as! String)!
            
            intMax = intMax + intSel
            aryReturnPd[i]["selQty"] =  String(intSel)
            aryReturnPd[i]["maxqty"] = String(intMax)
            aryReturnPd[i]["totRQty"] = String(intReturn)
        }
        
        /* 初始與設定 日期時間 picker */
        // Picker data 參數
        strCurrDate = dictReturn["sdate"] as! String  // 退貨日期
        let minDate = pubClass.subStr(purchaseDate, strFrom: 0, strEnd: 10) + "59"
        let maxDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 10) + "59"
        let defDate = pubClass.subStr(strCurrDate, strFrom: 0, strEnd: 12)
        
        mPicker = PickerDateTime.init(withUIField: edRDate, withDefMaxMin: [defDate, maxDate, minDate], NavyBarTitle: pubClass.getLang("selectdate"))
        mPicker.delegate = self
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "SaleReturnPdList") {
            initParm()  // init view param 相關參數
            
            let mVC = segue.destinationViewController as! SaleReturnPdList
            mVC.aryData = aryReturnPd
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
    }
    
    /**
     * #mark: PubPurReturnPdListDelegate
     * 退貨商品數量改變，本頁面相關資料變動
     */
    func PdQtyChange(SelectQty: Int, indexPath: NSIndexPath) {
        aryReturnPd[indexPath.row]["selQty"] = String(SelectQty)
        
        var tot = 0
        for dictPd in aryReturnPd {
            tot += Int(dictPd["price"] as! String)! * Int(dictPd["selQty"] as! String)!
        }
        
        labAmount.text = String(tot)
        edCustPrice.text = String(tot)
    }
    
    /**
     * #mark: PubPurReturnPdListDelegate
     * 退貨日期選擇，本頁面 strCurrDate 重新設定
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
     * act, switch 退貨全部取消
     */
    @IBAction func actSwchDelAll(sender: UISwitch) {
        btnDelAll.alpha = (sender.on) ? 1.0 : 0.0
        btnSave.enabled = (sender.on) ? false: true
    }
    
    /**
     * act, 點取 '確定' button, 退貨全部取消
     */
    @IBAction func actDelAll(sender: UIButton) {
        // 產生 http post data, http 連線儲存後跳離
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "sale"
        dictParm["act"] = "sale_returndel"
        dictParm["arg0"] = dictReturn["id"] as? String
        
        // HTTP 開始連線
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("purchase_returndelmsg")], withHandlerYes: {self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: self.HttpDelResponChk)}, withHandlerNo: {return})
    }
    
    /**
     * 資料刪除 callback, HTTP 連線後取得連線結果, 本頁面結束通知 parent 資料變動
     */
    private func HttpDelResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 回傳後跳離, 通知 parent 資料 reload
        let strMsg = (dictRS["result"] as! Bool != true) ? pubClass.getLang("err_trylatermsg") : pubClass.getLang("purchase_returndatadelcomplete")
        
        delegate?.PageNeedReload!(true)
        pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
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
        
        // 商品退貨的總數量 > 0
        var totRQty = 0
        for dictTmp in aryReturnPd as Array<Dictionary<String, AnyObject>> {
            let strNums = dictTmp["selQty"] as! String
            totRQty += Int(strNums)!
        }
        
        if (totRQty < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("sale_pleselreturnpdnumber"))
            return
        }
        
        // 彈出確認視窗
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("sale_mksurepurchasereturnmsg")], withHandlerYes: { self.saveData()}, withHandlerNo: {return})
        
        return
    }
    
    /**
    * 退貨資料編輯儲存程序
    */
    private func saveData() {
        // aryReturnPd 新增欄位 'rqty', server 端使用
        var aryPd: Array<Dictionary<String, AnyObject>> = []
        for dictTmp in aryReturnPd as Array<Dictionary<String, AnyObject>> {
            var dictPd = dictTmp
            dictPd["rqty"] = dictTmp["selQty"] as! String
            aryPd.append(dictPd)
        }
        
        // 產生 _REQUEST dict data
        var dictArg0: Dictionary<String, AnyObject> = [:]
        
        dictArg0["return_id"] = dictReturn["id"] as? String
        dictArg0["custprice"] = edCustPrice.text
        dictArg0["pd"] = aryPd
        dictArg0["sdate"] = strCurrDate

        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "sale"
        dictParm["act"] = "sale_returneditsave"
        
        do {
            let jobjData = try
                NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            
            return
        }
        
        // HTTP 開始連線
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            let bolRS = dictHTTPSRS["result"] as! Bool
            let strMsg = (bolRS == true) ? "datasavecompleted" : "err_trylatermsg"
            
            //self.delegate?.PageNeedReload!(bolRS)
            self.pubClass.popIsee(self, Msg: self.pubClass.getLang(strMsg), withHandler: {
                    self.delegate?.PageNeedReload!(bolRS)
                    self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}