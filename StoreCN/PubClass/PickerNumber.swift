//
// UIPickerView
//

import Foundation
import UIKit

/**
 * UIPickerView 公用程式，數字選取
 * 用於：數量選擇 => 一個欄位<BR>
 *      數值選擇 => (ex. 身高, 體重... 有無小數點)<BR>
 *      左選單 + 小數點 + 右選單<BR>
 *
 * @parm UITextField: 點取要作用的 TextView<BR>
 * @param PubClass:<BR>
 * @param Array<String>: 預設的數值由左至右, ex. ["0", ".", "0"]<BR>
 * @param Array<Dictionary<String, Int>>: 左右下拉數值的 最小/大值<BR>
 *   ex. ary[0] =><BR>
 *   'max'=250, 'min'=100, ary[1] => 'max'=1, 'min'=1, ary[1] => 'max'=9, 'min'=0
 */
class PickerNumber: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // property 設定
    private var pubClass: PubClass!
    private var mPKView = UIPickerView()
    private var mPickField: UITextField!
    private var arySelVal: Array<String>!  // 選單選取後，暫存的數值
    
    private var aryRowVal: Array<Array<String>>! = []  // 各個選單的資料 array data
    private var strBirth = ""  // 取得目前選擇數字轉為 String

    /**
     * PickerNumber init<br>
     */
    init(withUIField mField: UITextField, PubClass mPubClass: PubClass, DefAryVal aryDef: Array<String>!, MinMaxAry aryMaxMin: Array<Dictionary<String, Int>>!) {
        super.init()
        
        // 設定 UIPickerView
        mPKView.delegate = self

        // 參數設定
        pubClass = mPubClass
        mPickField = mField
        arySelVal = aryDef
        
        // 下拉選單預設值, 各個選單的資料 array data
        for (var i=0; i<aryDef.count; i++) {
            // 特殊欄位，小數點 '.'
            if (aryDef[i] == ".") {
                aryRowVal.append(["."])
                continue
            }
            
            // 產生 選單的資料
            let Max = Int(aryMaxMin[i]["max"]!)
            let Min = Int(aryMaxMin[i]["min"]!)
            var aryData: Array<String> = []
            
            for (var j=Min; j<=Max;j++) {
                aryData.append(String(j))
            }
            
            aryRowVal.append(aryData)
        }
        
        // 設定預設值
        for (var i=0; i<aryDef.count; i++) {
            if (aryDef[i] != ".") {
                // 最小值不一定 =0 會影響 position, 需要調整
                let intPosition = Int(aryDef[i])! - Int(aryRowVal[i][0])!
                mPKView.selectRow(intPosition , inComponent: i, animated: false)
            }
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        mPickField.inputView = mPKView
    }
    
    /**
    * #mark: UIPickerViewDelegate
    * 有幾個 '下拉選單'
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return arySelVal.count
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，有幾筆資料
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryRowVal[component].count
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return aryRowVal[component][row]
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，點取執行相關程序
     */
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        arySelVal[component] = aryRowVal[component][row]
        var strTxt = ""
        
        for (var i=0; i<arySelVal.count; i++) {
            strTxt += arySelVal[i]
        }
        
        mPickField.text = strTxt
    }
    
}