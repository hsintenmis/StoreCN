//
// Static TableView, 電話撥號, 簡訊發送
//

import UIKit
import Foundation


/**
 * protocol, RemindContactCont Delegate
 */
protocol RemindContactContDelegate {
    /**
     * 本頁面點取 '撥號', '發送簡訊', 回傳相關資料 parent 去處理
     */
    func SendDone(dictData: Dictionary<String, String>!, strType: String!)
}

/**
 * 今日提醒, 聯絡會員, Container
 */
class RemindContactCont: UITableViewController {
    var delegate = RemindContactContDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var edTel: UITextField!
    @IBOutlet weak var swchDial: UISwitch!
    @IBOutlet weak var swchSMS: UISwitch!
    @IBOutlet weak var btnDial: UIButton!
    @IBOutlet weak var btnSMS: UIButton!
    @IBOutlet weak var txtSMS: UITextView!
    
    // common property
    private let pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject>!
    var strType: String! // 辨識標記, 預約/到期
    
    // 其他參數
    private var dictSendData: Dictionary<String, String> = [:]
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view field value
        dictSendData["tel"] = dictAllData["membertel"] as? String
        labName.text = dictAllData["membername"] as? String
        edTel.text = dictSendData["tel"]
        
        // view field, textView 外觀樣式
        btnDial.layer.cornerRadius = 5
        btnSMS.layer.cornerRadius = 5
        btnDial.enabled = false
        btnSMS.enabled = false
        btnDial.alpha = 0.2
        btnSMS.alpha = 0.2
        
        txtSMS.layer.cornerRadius = 5
        txtSMS.layer.borderWidth = 1
        txtSMS.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtSMS.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor

        
        // 預約/到期 SMS 內容設定
        if (strType == "reser") {
            let strArg = (dictAllData["hh"] as! String) + ":" + (dictAllData["min"] as! String)
            dictSendData["msg"] = String(format: pubClass.getLang("FMT_remindsms_resver"), strArg)
        } else {
            let strArg = pubClass.formatDateWithStr(dictAllData["end_date"] as! String, type: 8)
            dictSendData["msg"] = String(format: pubClass.getLang("FMT_remindsms_course"), strArg)
        }
        
        txtSMS.text = dictSendData["msg"]
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        edTel.resignFirstResponder()
        
        return true
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // Container 轉入 撥號/SMS 主頁面
        if (strIdent == "RemindContactCont") {
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '撥號開關' switch
     */
    @IBAction func actSwchDial(sender: UISwitch) {
        btnDial.enabled = sender.on
        btnDial.alpha = (sender.on) ? 1.0 : 0.2
    }
    
    /**
     * act, 點取 'SMS開關' switch
     */
    @IBAction func actSwchSMS(sender: UISwitch) {
        btnSMS.enabled = sender.on
        btnSMS.alpha = (sender.on) ? 1.0 : 0.2
    }
    
    /**
     * act, 點取 '撥號' button
     */
    @IBAction func actDial(sender: UIButton) {
       delegate?.SendDone(dictSendData, strType: "Dial")
    }
    
    /**
     * act, 點取 '發送簡訊' button
     */
    @IBAction func actSMS(sender: UIButton) {
        delegate?.SendDone(dictSendData, strType: "SMS")
    }
    
}