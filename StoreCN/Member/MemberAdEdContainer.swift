//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class MemberAdEdContainer: UITableViewController, UITextFieldDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    @IBOutlet weak var edName: UITextField!
    
    @IBOutlet weak var labID: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var txtPsd: UITextField!
    @IBOutlet weak var swchGender: UISegmentedControl!
    @IBOutlet weak var txtTEL: UITextField!
    @IBOutlet weak var txtBirth: UITextField!
    @IBOutlet weak var txtHeigh: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtCNID: UITextField!
    @IBOutlet weak var txtWechat: UITextField!
    @IBOutlet weak var txtQQ: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtZip: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtAddr: UITextField!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    var strMode = "add"
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // textView array 與 val 值對應的 array data
    private var aryTxtView: Array<UITextField> = []
    private var aryField: Array<String> = []
    private var dictTxtView: Dictionary<String, UITextField> = [:]
    
    // 點取欄位，彈出虛擬鍵盤視窗, Picker 需要的資料
    private var dictPickParm: Dictionary<String, AnyObject> = [:]
    private var mPickerBirth: PickerDate!
    private var mPickerHeigh: PickerNumber!
    private var mPickerWeight: PickerNumber!
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定 key 對應 editView, 注意順序
        aryTxtView = [edName, txtTEL, txtBirth, txtHeigh, txtWeight, txtCNID, txtWechat, txtQQ, txtEmail, txtZip, txtCity, txtAddr]
        aryField = ["name", "tel","birth","height","weight","cid_cn","id_wechat","id_qq","email","zip","province","addr"]
        
        for loopi in (0..<aryField.count) {
            // textView 的 delegate
            aryTxtView[loopi].delegate = self
            
            // 設定到 dictTxtView, key 對應 UITextField
            dictTxtView[aryField[loopi]] = aryTxtView[loopi]
        }
        
        // Picker param 初始資料
        dictPickParm["birth_def"] = "19600101"
        dictPickParm["birth_min"] = "19150101"
        
        let intMaxYY = Int(pubClass.subStr(strToday, strFrom: 0, strEnd: 4))! - 10
        dictPickParm["birth_max"] = String(intMaxYY) + "1231"
        
        dictPickParm["H_def"] = ["160", ".", "0"]
        dictPickParm["H_minmax"] = [["max":220, "min":60], ["max":1, "min":1], ["max":9, "min":0]]
        dictPickParm["W_def"] = ["50", ".", "0"]
        dictPickParm["W_minmax"] = [["max":180, "min":10], ["max":1, "min":1], ["max":9, "min":0]]
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            self.initViewField()
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        // 編輯模式特殊處理
        if (strMode == "edit") {
            self.procEditMode()
        }
        
        /* Picker 設定 */
        // 生日欄位
        mPickerBirth = PickerDate(withUIField: txtBirth, PubClass: pubClass, withDefMaxMin: [dictPickParm["birth_def"] as! String, dictPickParm["birth_max"] as! String, dictPickParm["birth_min"] as! String], NavyBarTitle: pubClass.getLang("member_selectbirth"))
        
        // 身高/體重 欄位, 設定 'PickerNumber'
        mPickerHeigh = PickerNumber(withUIField: txtHeigh, PubClass: pubClass, DefAryVal: dictPickParm["H_def"] as! Array<String>, MinMaxAry: dictPickParm["H_minmax"] as! Array<Dictionary<String, Int>>)
        mPickerWeight = PickerNumber(withUIField: txtWeight, PubClass: pubClass, DefAryVal: dictPickParm["W_def"] as! Array<String>, MinMaxAry: dictPickParm["W_minmax"] as! Array<Dictionary<String, Int>>)
    }
    
    /**
     * 編輯模式特殊處理
     */
    private func procEditMode() {
        // 編輯模式下, 設定欄位初始資料
        edName.text = dictMember["membername"] as? String
        labID.text = dictMember["memberid"] as? String
        labSdate.text = pubClass.formatDateWithStr(dictMember["sdate"] as! String, type: "8s")
        
        txtPsd.text = dictMember["psd"] as? String
        txtTEL.text = dictMember["tel"] as? String
        txtCNID.text = dictMember["cid_cn"] as? String
        txtWechat.text = dictMember["id_wechat"] as? String
        txtQQ.text = dictMember["id_qq"] as? String
        txtEmail.text = dictMember["email"] as? String
        txtZip.text = dictMember["zip"] as? String
        txtCity.text = dictMember["province"] as? String
        txtAddr.text = dictMember["addr"] as? String
        
        let strGender = dictMember["gender"] as! String
        swchGender.selectedSegmentIndex = (strGender == "M") ? 0 : 1
        
        /* Picker 設定 */
        // 生日欄位
        if let strBirth = dictMember["birth"] as? String {
            let strYMDBirth = pubClass.subStr(strBirth, strFrom: 0, strEnd: 8)
            dictPickParm["birth_def"] = strYMDBirth
            txtBirth.text = pubClass.formatDateWithStr(strYMDBirth, type: 8)
        }
        
        // 身高/體重 欄位, 設定 'PickerNumber'
        if let strHeight = dictMember["height"] as? String {
            if (strHeight.characters.count > 1) {
                var strPointDigt = "0"
                let aryDigt = strHeight.characters.split{$0 == "."}.map(String.init)
                
                if (aryDigt.count == 3) {
                    strPointDigt = aryDigt[2]
                }
                
                let aryVal: Array<String> = [aryDigt[0], ".", strPointDigt]
                dictPickParm["H_def"] = aryVal
                txtHeigh.text = aryVal[0] + aryVal[1] + aryVal[2]
            }
        }
        
        if let strWeight = dictMember["weight"] as? String {
            if (strWeight.characters.count > 1) {
                var strPointDigt = "0"
                let aryDigt = strWeight.characters.split{$0 == "."}.map(String.init)
                
                if (aryDigt.count == 3) {
                    strPointDigt = aryDigt[2]
                }

                let aryVal: Array<String> = [aryDigt[0], ".", strPointDigt]
                dictPickParm["W_def"] = aryVal
                txtWeight.text = aryVal[0] + aryVal[1] + aryVal[2]
            }
        }
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 密碼 txtView
        if textField == txtPsd {
            textField.resignFirstResponder()
            return true
        }
        
        // 其他 txtView
        let currIndex = aryTxtView.indexOf(textField)!
        
        if (currIndex == (aryTxtView.count - 1)) {
            textField.resignFirstResponder()
            return true
        }
        
        aryTxtView[currIndex + 1].becomeFirstResponder()
        
        return true
    }
    
    /**
    * public, parent 調用, 本頁面資料整理檢查與回傳
    */
    func getPageData() -> Dictionary<String, AnyObject>? {
        var dictRS: Dictionary<String, AnyObject> = [:]
        
        // 檢查欄位 '密碼'
        if (txtPsd.text?.characters.count < 4) {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_err_psd"))
            return nil
        }
        
        dictRS["psd"] = txtPsd.text
        
        // 必填欄位檢查
        var aryTmpField = ["name", "tel", "birth", "height", "weight"]
        
        for strField in aryTmpField {
            if (dictTxtView[strField]!.text!.characters.count < 2) {
                dictTxtView[strField]!.becomeFirstResponder()
                pubClass.popIsee(self, Msg: pubClass.getLang("member_err_" + strField))
                return nil
            } else {
                if (strField == "birth") {
                    dictRS["birth"] = mPickerBirth.getStrDate()
                } else {
                    dictRS[strField] = dictTxtView[strField]!.text
                }
            }
        }
        
        // 其他欄位設定
        dictRS["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        
        aryTmpField = ["cid_cn","id_wechat","id_qq","email","zip","province","addr"]
        
        for strField in aryTmpField {
            dictRS[strField] = dictTxtView[strField]!.text
        }
        
        return dictRS
    }
    
}