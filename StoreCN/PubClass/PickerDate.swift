//
// UIDatePicker
// 

import Foundation
import UIKit

/**
 * UIDatePicker 公用程式，點取 'UITextField'
 * 彈出日期選擇虛擬鍵盤，完成後 field 顯示格式化的日期
 *
 * @parm UITextField: 點取要作用的 TextView<BR>
 * @param PubClass:<BR>
 * @param Array<String>: 預設的日期, maxDate, minDate, 8碼<BR>
 * @param String: 彈出虛擬鍵盤 navybar 的 title<BR>
 */
class PickerDate {
    // 日期預設值，最大/最小
    private var defDate = "19600101"
    private var maxDate = "20101231"
    private var minDate = "19150101"
    
    // UIDatePicker 設定
    private var pubClass: PubClass!
    private var mPickField: UITextField!
    private let dateFmtYMD: NSDateFormatter!  // 根據local顯示可閱讀的日期, ex. 2015年1月1日
    private var datePickerView: UIDatePicker!
    private var strCurrDate = ""  // 取得目前選擇的日期，轉為 8碼 string
    
    /**
    * init
    */
    init(withUIField mField: UITextField, PubClass mPubClass: PubClass, withDefMaxMin aryDefineDate: Array<String>!, NavyBarTitle strTitle: String!) {
        
        mPickField = mField
        pubClass = mPubClass
        dateFmtYMD = NSDateFormatter()
        
        defDate = aryDefineDate[0]
        maxDate = aryDefineDate[1]
        minDate = aryDefineDate[2]

        /**
         * UIDatePicker 初始設定
         * "dd-MM-yyyy HH:mm:ss"
         */
        // 初始與設定日期顯示樣式
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        dateFmtYMD.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFmtYMD.timeStyle = NSDateFormatterStyle.NoStyle
        dateFmtYMD.dateFormat = "yyyyMMdd"
        //dateFmtYMD.timeZone = NSTimeZone(abbreviation: "UTC");

        datePickerView.minimumDate = dateFmtYMD.dateFromString(minDate)!
        datePickerView.maximumDate = dateFmtYMD.dateFromString(maxDate)!
        
        // 設定 datePick value change 要執行的程序
        //datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        setDefVal(aryDefineDate[0])
        mPickField.inputView = datePickerView
        
        self.initKBBar(strTitle)
    }
    
    /**
     * UIDatePicker 設定預設值
     */
    func setDefVal(strDate: String) {
        let mDate = dateFmtYMD.dateFromString(strDate)!
        datePickerView.setDate(mDate, animated: false)
        //mPickField.inputView = datePickerView
    }
    
    /**
    * 取得目前選擇的日期，轉為 8碼 string
    */
    func getStrDate()->String {
        return strCurrDate
    }
    
    /**
     * 鍵盤輸入視窗的 'navybar' 設定
     * 日期欄位 點取彈出 資料輸入視窗 (虛擬鍵盤), 'InputView' 的頂端顯示 'navyBar'
     */
    private func initKBBar(strTitle: String) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true  // 半透明
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)  // 文字顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("select_ok"), style: UIBarButtonItemStyle.Plain, target: self, action: "PKDateDone")
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // 自訂一個 label 作為 NavyBar 的 Title
        let labTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 14.0))
        //let labTitle = UILabel()
        //labTitle.sizeToFit()
        
        labTitle.text = strTitle
        //labTitle.font = UIFont(name: "System", size: 14)
        labTitle.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: labTitle)
   
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "PKDateCancel")
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        mPickField.inputAccessoryView = toolBar
    }
    
    /**
     * DatePicker 點取　'done'
     */
    @objc private func PKDateDone() {
        mPickField.resignFirstResponder()
        self.PKDateChang(self.datePickerView)
    }
    
    /**
     * DatePicker 點取　'cancel'
     */
    @objc private func PKDateCancel() {
        mPickField.resignFirstResponder()
    }
    
    /**
     * UIDatePicker 自訂的 value change method
     * 使用方式如下:
     * datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"),
     *   forControlEvents: UIControlEvents.ValueChanged)
     */
    @objc private func PKDateChang(sender:UIDatePicker) {
        // ed/txt Field 欄位 顯示文字
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(sender.date), type: 8)
        })
        
        // 設定 strDate value
        strCurrDate = dateFmtYMD.stringFromDate(sender.date)
    }
}
