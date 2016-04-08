//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class StaffAdEdContainer: UITableViewController, UITextFieldDelegate {
    
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
    var pubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strMode: String!
    var dictMember: Dictionary<String, AnyObject> = [:]
    
    // textView array 與 val 值對應的 array data
    private var aryTxtView: Array<UITextField> = []
    private var aryField: Array<String> = []
    private var dictTxtView: Dictionary<String, UITextField> = [:]
    
    // 點取欄位，彈出虛擬鍵盤視窗
    private var mPickerBirth: PickerDate!
    private var mPickerHeigh: PickerNumber!
    private var mPickerWeight: PickerNumber!
    
    // 其他參數
    // Picker 需要的資料
    private var dictPickParm: Dictionary<String, AnyObject> = [:]
    private var strToday: String!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        strToday = pubClass.getDevToday()

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
        // set array, 注意順序
        aryTxtView = [edName, txtTEL, txtBirth, txtHeigh, txtWeight, txtCNID, txtWechat, txtQQ, txtEmail, txtZip, txtCity, txtAddr]
        aryField = ["name", "tel","birth","height","weight","cid","id_wechat","id_qq","email","zip","province","addr"]
        
        for loopi in (0..<aryField.count) {
            // textView 的 delegate
            aryTxtView[loopi].delegate = self
            dictTxtView[aryField[loopi]] = aryTxtView[loopi]
        }
        
        // 手動設定 textView 的 delegate, 密碼欄位
        txtPsd.delegate = self
        
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
        edName.text = dictMember["usrname"] as? String
        labID.text = dictMember["id"] as? String
        labSdate.text = pubClass.formatDateWithStr(dictMember["sdate"] as! String, type: "8s")
        
        txtTEL.text = dictMember["tel"] as? String
        txtCNID.text = dictMember["cid_cn"] as? String
        txtWechat.text = dictMember["id_wechat"] as? String
        txtQQ.text = dictMember["id_qq"] as? String
        txtEmail.text = dictMember["email"] as? String
        txtZip.text = dictMember["zip"] as? String
        txtCity.text = dictMember["province"] as? String
        txtAddr.text = dictMember["addr"] as? String
        txtPsd.text = dictMember["psd"] as? String
        
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
        var errMsgCode = ""
        
        if (edName.text!.characters.count < 2) {
            errMsgCode = "name"
        }
        if (txtTEL.text!.characters.count < 2) {
            errMsgCode = "tel"
        }
        
        let strBirth = mPickerBirth.getStrDate()
        if (strBirth.characters.count < 2) {
            errMsgCode = "birth"
        }
        
        if (errMsgCode != "") {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_err_" + errMsgCode))
            
            return nil
        }
        
        // 其他欄位設定
        dictRS["gender"] = (swchGender.selectedSegmentIndex == 0) ? "M" : "F"
        dictRS["birth"] = strBirth
        
        let aryTmpField = ["name", "tel", "height","weight", "cid","id_wechat","id_qq","email","zip","province","addr"]
        
        for strField in aryTmpField {
            dictRS[strField] = dictTxtView[strField]!.text
        }
        
        return dictRS
    }
    
}