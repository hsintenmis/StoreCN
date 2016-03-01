//
// UIDatePicker Date and Time
//

import Foundation
import UIKit

/**
 * protocol, PickerDateTime Delegate
 */
protocol PickerDateTimeDelegate {
    /**
     * Pickr view 虛擬鍵盤, 點取'完成'btn, strDateTime = 14碼
     */
    func doneSelectDateTime(strDateTime: String)
}

/**
 * 日期與時間選擇
 * UIDatePicker 公用程式，點取 'UITextField'
 * 彈出日期選擇虛擬鍵盤，完成後 field 顯示格式化的日期
 *
 * @parm UITextField: 點取要作用的 TextView<BR>
 * @param PubClass:<BR>
 * @param Array<String>: 預設的日期, maxDate, minDate, 12碼 or 14碼<BR>
 * @param String: 彈出虛擬鍵盤 navybar 的 title<BR>
 */
class PickerDateTime {
    // delegate
    var delegate = PickerDateTimeDelegate?()
    
    // 日期預設值，最大/最小
    private var defDate = "201601010001"
    private var maxDate = "203512312359"
    private var minDate = "201501010001"
    
    // UIDatePicker 設定
    private var pubClass: PubClass!
    private var mPickField: UITextField!  //  作用的 日期輸入 field
    private let dateFmtYMD: NSDateFormatter!  // 根據local顯示可閱讀的日期, ex. 2015年1月1日
    private var datePickerView: UIDatePicker!
    private var strCurrDate = ""  // 取得目前選擇的日期，轉為 14碼 string
    
    /**
    * init
    * UIDatePicker 初始設定
    * "dd-MM-yyyy HH:mm:ss"
    */
    init(withUIField mField: UITextField, withDefMaxMin aryDefineDate: Array<String>!, NavyBarTitle strTitle: String!) {
        
        mPickField = mField
        pubClass = PubClass()
        dateFmtYMD = NSDateFormatter()
        
        defDate = aryDefineDate[0]
        maxDate = aryDefineDate[1]
        minDate = aryDefineDate[2]
        
        /**
        * UIDatePicker 初始設定
        * "dd-MM-yyyy HH:mm:ss"
        */
        datePickerView = UIDatePicker()
        
        // 設定日期顯示樣式
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        dateFmtYMD.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFmtYMD.timeStyle = NSDateFormatterStyle.MediumStyle
        
        dateFmtYMD.dateFormat = "yyyyMMddHHmm"
        //dateFmtYMD.timeZone = NSTimeZone(abbreviation: "UTC");
        
        datePickerView.minimumDate = dateFmtYMD.dateFromString(minDate)!
        datePickerView.maximumDate = dateFmtYMD.dateFromString(maxDate)!
        
        // 設定預設值
        let mDate = dateFmtYMD.dateFromString(defDate)!
        datePickerView.setDate(mDate, animated: false)
        mPickField.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        
        // 設定 edDate 輸入鍵盤，樣式
        mField.inputView = datePickerView
        self.initKBBar(strTitle)
        
        // 設定 datePicker value change
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
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
     * DatePicker 點取　'done', 欄位值改變, @objc 注意用法
     */
    @objc private func PKDateDone() {
        mPickField.resignFirstResponder()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
        
        // 設定 strDate value
        strCurrDate = dateFmtYMD.stringFromDate(self.datePickerView.date)
        
        delegate?.doneSelectDateTime(strCurrDate)
    }
    
    /**
     * DatePicker 點取　'cancel'
     */
    func PKDateCancel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.strCurrDate, type: 14)
        })
        
        mPickField.resignFirstResponder()
    }
    
    /**
     * DatePicker Value change
     */
    @objc private func datePickerValueChanged(sender:UIDatePicker) {
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
    }
    

}
