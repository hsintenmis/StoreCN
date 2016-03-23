//
// with ContainerView, 調用公用 class 'PubPurReturnPdList'
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨退回，編輯退貨項目與相關資料
 */
class PurchaseReturnEdit: UIViewController, PubPurReturnPdListDelegate , PickerDateTimeDelegate {
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
    var dictPurchasePd: Dictionary<String, AnyObject>!  // 進貨商品資料
    var purchaseDate: String!  // 進貨日期
    
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
        let minDate = pubClass.subStr(purchaseDate, strFrom: 0, strEnd: 10) + "59"
        let maxDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 10) + "59"
        let defDate = pubClass.subStr(strToday, strFrom: 0, strEnd: 12)
        strCurrDate = defDate
        
        mPicker = PickerDateTime.init(withUIField: edRDate, withDefMaxMin: [defDate, maxDate, minDate], NavyBarTitle: pubClass.getLang("selectdate"))
        mPicker.delegate = self
        
        // field 設定
        btnDelAll.alpha = 0.0
        labAmount.text = dictReturn["price"] as? String
        edCustPrice.text = dictReturn["custprice"] as? String
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
    func initViewField() {
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let strIdent = segue.identifier
        
        return
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
        dictParm["page"] = "purchase"
        dictParm["act"] = "purchase_returndel"
        dictParm["arg0"] = dictReturn["id"] as? String
        
        // HTTP 開始連線
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("purchase_returndelmsg")], withHandlerYes: {self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: self.HttpSaveResponChk)}, withHandlerNo: {return})
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 回傳後跳離, 通知 parent 資料 reload
        let strMsg = (dictRS["result"] as! Bool != true) ? pubClass.getLang("err_trylatermsg") : pubClass.getLang("purchase_returndatadelcomplete")
        
        delegate?.PageNeedReload!(true)
        pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {

    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

