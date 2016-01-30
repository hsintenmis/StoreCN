//
// UIDatePicker
// 

import Foundation
import UIKit

/**
 * UIDatePicker 公用程式，點取 'UITextField'
 * 彈出日期選擇虛擬鍵盤，完成後 field 顯示格式化的日期
 */
class PickerDate {
    var DatePickField: UITextField!

    // UIDatePicker 設定
    private let defBirth = "19600101"
    private let defMaxYMD = "20101231"
    private let defMinYMD = "19150101"
    
    private let dateFmt_YMD = NSDateFormatter()  // YYMMDD
    private let dateFmt_Read = NSDateFormatter()  // 根據local顯示, ex. 2015年1月1日
    private let datePickerView:UIDatePicker = UIDatePicker()
    
    // 文字設定
    private var strBirth = ""  // 取得目前選擇的日期，轉為 8碼 string
    private var strTxtDone: String!
    private var strTxtCancel: String!
    
    /**
    * init
    * @parm UITextField:
    * @param Array<String>: bar btn 顯示的文字, 0=完成, 1=取消
    */
    init(uiField: UITextField, aryStrTxt: Array<String>!) {
        strTxtDone = aryStrTxt[0]
        strTxtCancel = aryStrTxt[1]
        DatePickField = uiField
    }
    
    /**
     * UIDatePicker 初始設定
     * "dd-MM-yyyy HH:mm:ss"
     */
    func initDatePicker() {
        // 設定日期顯示樣式
        dateFmt_YMD.dateFormat = "yyyyMMdd"
        dateFmt_Read.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFmt_Read.timeStyle = NSDateFormatterStyle.NoStyle
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        datePickerView.minimumDate = dateFmt_YMD.dateFromString(defMinYMD)!
        datePickerView.maximumDate = dateFmt_YMD.dateFromString(defMaxYMD)!
        
        // 設定 datePick value change 要執行的程序
        //datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        DatePickField.inputView = datePickerView
        self.initKBBar()
    }
    
    /**
     * UIDatePicker 設定預設值
     */
    func setDefVal() {
        let mDate = dateFmt_YMD.dateFromString(defBirth)!
        datePickerView.setDate(mDate, animated: false)
        DatePickField.inputView = datePickerView
    }
    
    /**
    * 取得目前選擇的日期，轉為 8碼 string
    */
    func getStrDate()->String {
        return strBirth
    }
    
    /**
     * 鍵盤輸入視窗的 'bar' 設定
     * 生日欄位 點取彈出 資料輸入視窗 (虛擬鍵盤), 'InputView' 的頂端顯示 'navyBar'
     */
    private func initKBBar() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true  // 半透明
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)  // 文字顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: strTxtDone, style: UIBarButtonItemStyle.Plain, target: self, action: "PKDateDone")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: strTxtCancel, style: UIBarButtonItemStyle.Plain, target: self, action: "PKDateCancel")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        DatePickField.inputAccessoryView = toolBar
    }
    
    /**
     * DatePicker 點取　'done'
     */
    @objc private func PKDateDone() {
        DatePickField.resignFirstResponder()
        self.PKDateChang(self.datePickerView)
    }
    
    /**
     * DatePicker 點取　'cancel'
     */
    @objc private func PKDateCancel() {
        DatePickField.resignFirstResponder()
    }
    
    /**
     * UIDatePicker 自訂的 value change method
     * 使用方式如下:
     * datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"),
     *   forControlEvents: UIControlEvents.ValueChanged)
     */
    @objc private func PKDateChang(sender:UIDatePicker) {
        // edBirth 顯示文字
        dispatch_async(dispatch_get_main_queue(), {
            self.DatePickField.text = self.dateFmt_Read.stringFromDate(sender.date)
        })
        
        // 設定 strBirth value
        strBirth = dateFmt_YMD.stringFromDate(sender.date)
    }
}
