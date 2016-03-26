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
class PickerDate: NSObject, KBNavyBarDelegate {
    // 日期預設值，最大/最小
    private var defDate = "19600101"
    private var maxDate = "20101231"
    private var minDate = "19150101"
    
    // UIDatePicker 設定
    private var pubClass: PubClass!
    private var mPickField: UITextField!
    private let dateFmtYMD = NSDateFormatter()  // 根據local顯示可閱讀的日期, ex. 2015年1月1日
    private var datePickerView: UIDatePicker!
    private var strCurrDate = ""  // 取得目前選擇的日期，轉為 8碼 string
    
    private let mKBNavyBar = KBNavyBar()

    /**
    * init
    */
    init(withUIField mField: UITextField, PubClass mPubClass: PubClass, withDefMaxMin aryDefineDate: Array<String>!, NavyBarTitle strTitle: String!) {
        
        super.init()
        
        mPickField = mField
        pubClass = mPubClass
        
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
        setDefVal(aryDefineDate[0])
        
        
        // 設定 edDate 輸入鍵盤，樣式
        mPickField.inputView = datePickerView
        mKBNavyBar.delegate = self
        mPickField.inputAccessoryView = mKBNavyBar.getKBBar(strTitle)
    }
    
    /**
     * UIDatePicker 設定預設值
     */
    func setDefVal(strDate: String) {
        let mDate = dateFmtYMD.dateFromString(strDate)!
        datePickerView.setDate(mDate, animated: false)
        strCurrDate = strDate
    }
    
    /**
    * 取得目前選擇的日期，轉為 8碼 string
    */
    func getStrDate()->String {
        return strCurrDate
    }
    
    /**
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'done'
     */
    func KBBarDone() {
        mPickField.resignFirstResponder()
        self.PKDateChang(self.datePickerView)
    }
    
    /**
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'cancel'
     */
    func KBBarCancel() {
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