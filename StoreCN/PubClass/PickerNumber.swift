//
// UIPickerView
//

import Foundation
import UIKit

/**
 * UIPickerView 公用程式，數字選取
 */
class PickerNumber: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // property 設定
    private var mPKView = UIPickerView()
    private var mPickField: UITextField!
    private var arySelTxt = ["0", ".", "0"]
    
    // public property
    /** 是否有含小數點 */
    var hasNumberPoint = false
    
    /** 左邊數字 String array */
    var aryLeftNumber: Array<String> = []
     
    /** 右邊數字 String array, 無小數點不用設定 */
    var aryRightNumber: Array<String> = []
    
    // 文字設定
    private var strBirth = ""  // 取得目前選擇數字轉為 String
    private var strTxtDone: String!
    private var strTxtCancel: String!
    
    /**
     * init
     * @parm UITextField:
     * @param Array<String>: bar btn 顯示的文字, 0=完成, 1=取消
     */
    init(uiField: UITextField, aryStrTxt: Array<String>!, DefStrVal defVal: String!) {
        super.init()
        
        strTxtDone = aryStrTxt[0]
        strTxtDone = aryStrTxt[1]
        
        // 設定 UIPickerView
        mPKView.delegate = self
        mPKView.selectRow(Int(defVal)!, inComponent: 0, animated: false)
        
        mPickField = uiField
        mPickField.inputView = mPKView
    }
    
    /**
    * #mark: UIPickerViewDelegate
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return (!hasNumberPoint) ? 1 : 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (component) {
        case 0:
            return aryLeftNumber.count
        case 1:
            return 1
        case 2:
            return aryRightNumber.count
        default:
            return 0
        }
    }
    
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch (component) {
        case 0:
            return aryLeftNumber[row]
        case 1:
            return "."
        case 2:
            return aryRightNumber[row]
        default:
            return ""
        }
    }
    
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (!hasNumberPoint) {
            mPickField.text = aryLeftNumber[row]
            return
        }
            
        // 多個欄位，需紀錄選擇的資料再重新組合
        switch (component) {
        case 0:
            arySelTxt[component] = aryLeftNumber[row]
            break;
        case 2:
            arySelTxt[component] = aryRightNumber[row]
            break;
        default: break
        }
        
        mPickField.text = arySelTxt[0] + arySelTxt[1] + arySelTxt[2]
    }
    
}