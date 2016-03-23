//
// Calendar, 使用 UICollectionView 產生
// 
// 需指定開頭的星期名稱為 sun, mon 或其他, 'aryFixWeek' 設定
// 需設定 TimeZone, ex. +8
//
// 每個 cell 對應 aryBlock 資料 (日期，資料內容)
// ex. aryBlock[0]  表示第 0 列日期資料（共六列，每列7個cell），
//  aryBlock[0][n]: n = 0 ~ 6 , 第一列 sun ~ sat 的資料
//  aryBlock[0][0] =>
//      'txtDay': 顯示日期  string, ex. "2", 非當月顯示 ""
//      'data': anyObject, 資料內容，交由上層 class 自行處理
//

import UIKit
import Foundation

/**
* Calendar, 使用 UICollectionView 產生
* 需指定開頭的星期名稱為 sun, mon 或其他, 'aryFixWeek' 設定
* 需設定 TimeZone, ex. +8
*/
class CalendarCellData {
    // 固定參數
    let intTimeZone: Int = 8 // 時區 +8
    
    // common property
    private var pubClass = PubClass()
    
    // public property
    let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0", "blue":"66CCFF", "black":"000000", "green":"99CC33"]
    
    // 月曆相關參數設定
    private let aryFixWeek = ["Sun", "Mon","Tue","Wed","Thu","Fri","Sat"]
    
    // 系統 Calendar 參數設定
    let mCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    let mNSDate = NSDate()
    let components: NSDateComponents
    
    /**
     * init
     */
    init() {
        components = mCalendar!.components(NSCalendarUnit.Month, fromDate: mNSDate)
    }
    
    /**
     * 根據指定的 YYYYMM, 取得該月份全部的 block data
     * @param Dictionary<String, AnyObject> : 指定月份個日期的資料，or nil
     */
    func getAllData(dictYYMM: Dictionary<String, String>, DataSource datasource: Dictionary<String, AnyObject>? )->Array<Array<Dictionary<String, AnyObject>>> {
        // 初始相關參數
        var aryAllBlock: Array<Array<Dictionary<String, AnyObject>>> = []
        
        //  各日期資料如: 'dd03' => ary or dict, 'dd10'...,  須注意前置碼 'dd'
        var dictAllData: Dictionary<String, AnyObject> = [:]
        
        if let tmpData = datasource {
            dictAllData = tmpData
        }
        
        components.year = Int(dictYYMM["YY"]!)!
        components.month = Int(dictYYMM["MM"]!)!
        components.hour = intTimeZone;
        components.minute = 0;
        components.second = 1;
        
        // 指定月份的第一天，最後一天，格式為 NSDate
        components.day = 1
        let firstDateOfMonth: NSDate = mCalendar!.dateFromComponents(components)!
        
        // 最後一天
        components.month += 1
        components.day = 0
        let lastDateOfMonth: NSDate = mCalendar!.dateFromComponents(components)!
        
        // 取得 10月01日 是星期幾, 最後一天是幾號
        let firstWeekName: String = pubClass.subStr(getFormatYMD(firstDateOfMonth), strFrom: 8, strEnd: 11)
        let lastMonthDay: Int = Int(pubClass.subStr(getFormatYMD(lastDateOfMonth), strFrom: 6, strEnd: 8))!
        
        // 產生月曆每個 'Block' 的資料
        var currDay: Int = 1;  // 目前處理 aryAllBlock 的 '日期'
        
        // 月曆 第一個 資料列
        var arySect: Array<Dictionary<String, AnyObject>> = []
        var dictBlock: Dictionary<String, AnyObject>
        
        var strDayKey = ""  // ex. 'dd01'
        var isStartSet = false  // 是否開始設定資料 flag
        
        for loopi in (0..<7) {
        //for (var loopi = 0; loopi < 7; loopi++) {
            dictBlock = [:]
            dictBlock["data"] = nil
            
            // 設定 block 從第幾個開始有資料
            if (firstWeekName == aryFixWeek[loopi] && !isStartSet) {
                isStartSet = true
            }
            
            if (!isStartSet) {
                dictBlock["txtDay"] = ""
                arySect.append(dictBlock)
                
                continue
            }
            
            // 指定日期是否有資料
            strDayKey = "dd" + String(currDay)
            if let tmpData = dictAllData[strDayKey] {
                dictBlock["data"] = tmpData
            }
            
            // 其他欄位設定，dict data 加入 '列' array
            dictBlock["txtDay"] = String(currDay)
            currDay += 1
            arySect.append(dictBlock)
        }
        
        aryAllBlock.append(arySect)
        
        // 其他 sect 列設定, 2~6 列
        for _ in (1..<6) {
        //for (var currSect = 1; currSect <= 5; currSect++) {
            arySect = []
            
            // 指定的 sect 列, 設定「星期幾」的資料
            for _ in (0..<7) {
                dictBlock = [:]
                dictBlock["data"] = nil
                
                if (currDay <= lastMonthDay) {
                    dictBlock["txtDay"] = String(currDay)
                    
                    // 指定日期是否有資料
                    strDayKey = "dd" + String(currDay)
                    if let tmpData = dictAllData[strDayKey] {
                        dictBlock["data"] = tmpData
                    }
                }
                else {
                    dictBlock["txtDay"] = ""
                }
                
                arySect.append(dictBlock)
                currDay += 1
            }
            
            aryAllBlock.append(arySect)
        }
        
        return aryAllBlock
    }
    
    /**
     * 回傳格式化後的 日期/時間
     * http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
     *
     * 本 class 需要的格式回傳如: '20151031Wed' (YYYY MM DD Week)
     */
    func getFormatYMD(mDate: NSDate)->String {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd ccc HH:mm"
        dateFormatter.dateFormat = "yyyyMMddccc"
        
        // 顯示如 '20160201Mon', 星期名稱一定是'英文'
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return dateFormatter.stringFromDate(mDate)
    }
    
}