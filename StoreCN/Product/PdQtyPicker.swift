//
// UIPickerView
//

import Foundation
import UIKit

/**
 * protocol, PurchasePdSelt Delegate
 */
protocol PickerQtyDelegate {
    /**
     * Pickr view, 點取 '完成' / '取消'時， parent class 執行相關動作
     */
    func QtySelecteDone(SelectQty: Int)
    func QtySelecteCancel()
}

/**
 * UIPickerView 公用程式，數量選擇<BR>
 *
 * @param Int: 預設的數值<BR>
 * @param Array<Int>: 下拉數值的 最小/大值<BR>
 */
class PickerQty: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    // Delegate
    var delegate = PickerQtyDelegate?()
    
    // property 設定
    private var pubClass = PubClass()
    private var mPKView = UIPickerView()
    
    // 參數設定
    private var currIndexPath: NSIndexPath?
    
    private var mTxtField: UITextField!
    private var aryRowVal: Array<String> = []  // 下拉選單的資料
    
    /**
    * PickerNumber init<br>
    */
    init(edView: UITextField, DefVal val: Int!, MinMaxAry aryMaxMin: Array<Int>!, NavyBarTitle strTitle: String!) {
        super.init()

        // 參數設定
        mPKView.delegate = self
        mTxtField = edView
        
        // 設定每個 Picker row 的 array data
        for (var i = aryMaxMin[0]; i < aryMaxMin[1]; i++) {
            aryRowVal.append(String(i))
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        mTxtField.inputView = mPKView
        initKBBar(strTitle)
    }
    
    /**
    * 設定預設值
    */
    func ShowQtyView(DefaultVal val: Int, tableIndexPath: NSIndexPath) {
        mPKView.selectRow(val, inComponent: 0, animated: false)
        
        print(mPKView.frame.size.height)
        
        currIndexPath = tableIndexPath
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 有幾個 '下拉選單'
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，有幾筆資料
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryRowVal.count
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return aryRowVal[row]
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，點取 Item 後執行相關程序
     */
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    /**
     * 鍵盤輸入視窗的 'navybar' 設定
     * 顯示 '完成' 與 '取消'
     */
    private func initKBBar(strTitle: String) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true  // 半透明
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)  // 文字顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("select_ok"), style: UIBarButtonItemStyle.Plain, target: self, action: "SelectDone")
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // 自訂一個 label 作為 NavyBar 的 Title
        let labTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 14.0))
        //let labTitle = UILabel()
        //labTitle.sizeToFit()
        
        labTitle.text = strTitle
        //labTitle.font = UIFont(name: "System", size: 14)
        
        labTitle.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: labTitle)
        
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "SelectCancel")
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        mTxtField.inputAccessoryView = toolBar
    }

    /**
     * Picker 點取　'done'
     */
    @objc private func SelectDone() {        
        delegate?.QtySelecteDone(mPKView.selectedRowInComponent(0))
    }
    
    /**
     * Picker 點取　'cancel'
     */
    @objc private func SelectCancel() {
        delegate?.QtySelecteCancel()
    }
        
}