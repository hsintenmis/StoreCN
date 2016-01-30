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
    @IBOutlet weak var txtRePsd: UITextField!
    
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
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // public property, 上層 parent 設定
    var strToday: String!
    var strMode = "add"
    
    // textView array 與 val 值對應的 array data
    private var aryTxtView: Array<UITextField> = []
    private var aryField: Array<String> = []
    
    // 其他 class
    private var mPickerDate: PickerDate!
    private var mPickerHeigh: PickerNumber!
     
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
        
        /* Picker 設定 */
        // 生日欄位
        let aryTxt = [pubClass.getLang("done"), pubClass.getLang("cancel")]
        mPickerDate = PickerDate(uiField: txtBirth, aryStrTxt: aryTxt)
        
        // 身高欄位
        mPickerHeigh = PickerNumber(uiField: txtHeigh, aryStrTxt: aryTxt, DefStrVal: "160")
        mPickerHeigh.hasNumberPoint = true
        var loopi = 0;
        var aryTmp: Array<String> = []
        for (loopi = 50; loopi <= 250; loopi++) {
           aryTmp.append(String(loopi))
        }
        mPickerHeigh.aryLeftNumber = aryTmp
        
        aryTmp = []
        for (loopi = 0; loopi <= 9; loopi++) {
            aryTmp.append(String(loopi))
        }
        
        mPickerHeigh.aryRightNumber = aryTmp
        
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
        aryField = ["name", "tel","birth","height","weight","cid_cn","id_wechat","id_qq","email","zip","province","addr"]
        
        for(var loopi = 0; loopi < aryField.count; loopi++) {
            // TODO 若為編輯模式，設定初始值
            //aryTxtView[loopi].text = dictMember[aryField[loopi]]
            
            // textView 的 delegate
            aryTxtView[loopi].delegate = self
        }
        
        // 手動設定 textView 的 delegate, 密碼欄位
        txtPsd.delegate = self
        txtRePsd.delegate = self
        
        // 設定 'edBirth' 欄位，彈出自訂的 '日期選擇' 視窗
        mPickerDate.initDatePicker()
        
        // 編輯模式特殊處理
        self.procEditMode()
    }
    
    /**
     * 編輯模式特殊處理
     */
    private func procEditMode() {
        if (strMode != "edit") {
            // 生日初始預設值
            mPickerDate.setDefVal()
            return
        }
        
        // 編輯模式下, 設定欄位初始資料
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 密碼 txtView
        if textField == txtPsd {
            txtRePsd.becomeFirstResponder()
            return true
        }
        if textField == txtRePsd {
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
    
}
