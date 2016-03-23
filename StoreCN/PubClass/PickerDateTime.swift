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
class PickerDateTime: NSObject, KBNavyBarDelegate {
    // delegate
    var delegate = PickerDateTimeDelegate?()
    
    // 日期預設值，最大/最小
    private var defDate = "201601010001"
    private var maxDate = "203512312359"
    private var minDate = "201501010001"
    
    // UIDatePicker 設定
    private let pubClass = PubClass()
    private let dateFmtYMD = NSDateFormatter()  // 根據local顯示可閱讀的日期, ex. 2015年1月1日
    private let datePickerView = UIDatePicker()
    private let mKBNavyBar = KBNavyBar()
    
    private var mPickField: UITextField!  //  作用的 日期輸入 field
    private var strCurrDate = ""  // 取得目前選擇的日期，轉為 14碼 string

    /**
    * init
    * UIDatePicker 初始設定
    * "dd-MM-yyyy HH:mm:ss"
    */
    init(withUIField mField: UITextField, withDefMaxMin aryDefineDate: Array<String>!, NavyBarTitle strTitle: String!) {
        
        super.init()
        
        mPickField = mField
        defDate = aryDefineDate[0]
        maxDate = aryDefineDate[1]
        minDate = aryDefineDate[2]
        
        /**
        * UIDatePicker 初始設定
        * "dd-MM-yyyy HH:mm:ss"
        */
        
        // 設定日期顯示樣式
        datePickerView.datePickerMode = UIDatePickerMode.Date
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
        mKBNavyBar.delegate = self
        mPickField.inputAccessoryView = mKBNavyBar.getKBBar(strTitle)

        // 設定 datePicker value change
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /**
     * #selector, Self
     * DatePicker Value change
     */
    @objc private func datePickerValueChanged(sender:UIDatePicker) {
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
    }
    
    /**
    * #mark: KBNavyBarDelegate
    * 虛擬自訂鍵盤　toolbar 點取 'done'
    */
    func KBBarDone() {
        mPickField.resignFirstResponder()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.dateFmtYMD.stringFromDate(self.datePickerView.date), type: 14)
        })
        
        // 設定 strDate value
        strCurrDate = dateFmtYMD.stringFromDate(self.datePickerView.date)
        
        delegate?.doneSelectDateTime(strCurrDate)
    }
    
    /**
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'cancel'
     */
    func KBBarCancel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.mPickField.text = self.pubClass.formatDateWithStr(self.strCurrDate, type: 14)
        })
        
        mPickField.resignFirstResponder()
    }
    
}
