//
//
//

import UIKit
import Foundation

/**
 * 店家更改密碼
 */
class ConfigPsd: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var edOrg: UITextField!
    @IBOutlet weak var edNew: UITextField!
    @IBOutlet weak var edRep: UITextField!
    
    // common property
    var pubClass = PubClass()
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == edOrg {
            textField.resignFirstResponder()
        }
        else if (textField == edNew) {
            edRep.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    /**
     * act, 點取 '儲存'
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let strOrg = pubClass.getAppDelgVal("V_USRPSD") as! String
        var errCode = ""
        
        // 檢查輸入欄位
        if ((edNew.text! != edRep.text!) || edNew.text!.characters.count < 4) {
            errCode = "new"
        }
        
        if (edOrg.text! != strOrg) {
            errCode = "org"
        }
        
        if (errCode != "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("password_err_" + errCode))
            
            return
        }
        
        pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("datasendplzconfirmmsg")], withHandlerYes: {self.saveData()}, withHandlerNo: {})
        
        return
    }
    
    /**
     * 資料儲存程序，完成後跳離
     */
    private func saveData() {
        // http 連線
        
        // 儲存成功，重新設定 app 全域/prefer密碼
        /*
        let mPref = NSUserDefaults(suiteName: "standardUserDefaults")!
        mPref.setObject(edNew.text, forKey: "psd")
        pubClass.setAppDelgVal("V_USRPSD", withVal: edNew.text!)
        */
        
    }
    
    /**
     * act, 點取 '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}