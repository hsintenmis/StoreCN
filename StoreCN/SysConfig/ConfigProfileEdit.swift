//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class ConfigProfileEdit: UITableViewController, UITextFieldDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    @IBOutlet weak var edName: UITextField!
    @IBOutlet weak var txtTEL: UITextField!
    @IBOutlet weak var txtUsrName: UITextField!
    @IBOutlet weak var txtWechat: UITextField!
    @IBOutlet weak var txtQQ: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtAddr: UITextField!
    
    // common property
    var pubClass: PubClass!
    
    // 本頁面需要的資料
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // EditField, 回傳資料欄位, 存檔資料欄位 都設定為 array, 有順序
    private var aryUITextField: Array<UITextField> = []
    
    private let aryRSField = ["store_name", "tel", "store_master", "id_wechat", "id_qq", "email", "zip", "province", "addr"]
    
    private let arySaveField = ["edStoreName", "edTel", "edStoreMaster", "edWechat", "edQQ", "edEmail", "edZip", "edProvince", "edAddr"]
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // editField 加入 array
        aryUITextField.append(edName)
        aryUITextField.append(txtTEL)
        aryUITextField.append(txtUsrName)
        aryUITextField.append(txtWechat)
        aryUITextField.append(txtQQ)
        aryUITextField.append(txtEmail)
        aryUITextField.append(txtZip)
        aryUITextField.append(txtCity)
        aryUITextField.append(txtAddr)
        
        // 設定 UITextField delegate
        for tmpTxtField in aryUITextField {
            tmpTxtField.delegate = self
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        reConnHTTP()
    }
    
    /**
     * 頁面資料重整，檢查是否有資料
     */
    private func relaodPage() {
        for (var i=0; i < aryRSField.count; i++) {
            aryUITextField[i].text = dictAllData[aryRSField[i]] as? String
        }
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "homepage"
        mParam["act"] = "homepage_getstoreprofile"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            self.dictAllData = dictData["data"] as! Dictionary<String, AnyObject>
            self.relaodPage()
        })
    }

    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtUsrName || textField == txtAddr) {
            textField.resignFirstResponder()
            
            return true
        }
        
        // 其他 txtView
        let nextIndex = aryUITextField.indexOf(textField)! + 1
        aryUITextField[nextIndex].becomeFirstResponder()
        
        return true
    }
    
    /**
     * public
     * 取得本頁面編修的資料，回傳給 parent 使用
     */
    func getPageData() -> Dictionary<String, String>! {
        var dictRS: Dictionary<String, String> = [:]
        
        for (var i=0; i < aryRSField.count; i++) {
            dictRS[arySaveField[i]] = aryUITextField[i].text
        }
        
        return dictRS
    }
}
