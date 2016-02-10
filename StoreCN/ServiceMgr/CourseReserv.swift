//
// CollectionView
//

import UIKit
import Foundation

/**
 * 療程預約
 */
class CourseReserv: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var coltviewCalendar: UICollectionView!
    @IBOutlet weak var tableReserv: UITableView!
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labYY: UILabel!
    @IBOutlet weak var labMMDD: UILabel!
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    // dictAllData => 'data', 'pd', 'member', 'today'
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 本 class 需要的資料設定
    private var aryReservData: Array<Dictionary<String, AnyObject>>!
    private var aryMember: Array<Dictionary<String, AnyObject>>?
    private var aryCourse: Array<Dictionary<String, AnyObject>>!
    private var aryReservDataDay: Array<Dictionary<String, AnyObject>> = [] // 當日預約資料 array
    
    // 其他參數設定
    private var mCalendarCellData = CalendarCellData()
    private var currYYMM: Dictionary<String, String> = [:]  // 目前選擇的 YYMMDD
    private var aryBlockData: Array<Array<Dictionary<String, AnyObject>>> = []
    
    // 本月曆的起始 YYMM, 'aryReservData' 對應的 position
    private var positionReservData = 0
    private var positionToday = 0
    private let firstYYMM = "201501"
    private var lastYYMM = "202512"
    
    // 顏色
    private var dictColor: Dictionary<String, String>!
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        // 固定初始參數
        super.viewDidLoad()
        dictColor = pubClass.dictColor
        
        // 檢查是否有會員
        if let tmpData = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
        
        // 設定預約/療程DB 資料
        aryReservData = dictAllData["data"] as! Array<Dictionary<String, AnyObject>>
        aryCourse = dictAllData["pd"] as! Array<Dictionary<String, AnyObject>>

        // 設定今天日期 YYMMDD
        currYYMM = ["YY":pubClass.subStr(strToday, strFrom: 0, strEnd: 4), "MM":pubClass.subStr(strToday, strFrom: 4, strEnd: 6), "DD":pubClass.subStr(strToday, strFrom: 6, strEnd: 8)]

        // 設定 aryReservData data position
        let strYYMM = pubClass.subStr(strToday, strFrom: 0, strEnd: 6)
        for (var i=0; i<aryReservData.count; i++) {
            if (strYYMM == aryReservData[i]["yymm"] as! String) {
                positionReservData = i
                positionToday = i
                break
            }
        }

        // 初始與顯示頁面資料
        initViewField()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {

        })
    }

    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
        // 取得指定月份預約資料
        let dictReservMM = aryReservData[positionReservData]["dd_data"] as? Dictionary<String, AnyObject>
        
        // 設定 calendar data
        aryBlockData = mCalendarCellData.getAllData(currYYMM, DataSource: dictReservMM)
        coltviewCalendar.reloadData()
        
        labYY.text = currYYMM["YY"]
        labMM.text = pubClass.getLang("mm_" + currYYMM["MM"]!)
        labMMDD.text = String(format: pubClass.getLang("FMT_MMDD"), Int(currYYMM["MM"]!)!, Int(currYYMM["DD"]!)!)
        
        // 設定 tableview, 當日預約資料列表
        aryReservDataDay = []
        
        let strKey = "dd" + String(format: "%d", Int(currYYMM["DD"]!)!)
        if ((dictReservMM) != nil) {
            if let tmpAry = dictReservMM![strKey] as? Array<Dictionary<String, AnyObject>> {
                aryReservDataDay = tmpAry
            }
        }

        tableReserv.reloadData()
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 6
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mCell: PubCalendarCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellPubCalendar", forIndexPath: indexPath) as! PubCalendarCell
        
        let dictBlock: Dictionary<String, AnyObject> = aryBlockData[indexPath.section][indexPath.row]
        let strDay = dictBlock["txtDay"] as! String
        
        // 樣式/外觀/顏色
        mCell.labDate.text = strDay
        mCell.labDate.layer.borderWidth = 1
        mCell.labDate.layer.cornerRadius = 25 / 2  // 日期文字的高度 storyboard 設定
        mCell.labDate.layer.borderColor = (pubClass.ColorHEX(dictColor["white"]!)).CGColor
        mCell.labDate.layer.backgroundColor = (pubClass.ColorHEX(dictColor["white"]!)).CGColor
        
        // 沒有日期資料
        if (strDay.characters.count < 1) {
            return mCell
        }
        
        // 有資料的日期
        if dictBlock["data"] != nil {
            mCell.labDate.layer.borderColor = (pubClass.ColorHEX(dictColor["green"]!)).CGColor
        }
        
        // 目前選擇的日期
        if (currYYMM["DD"] == String(format: "%02d", Int(strDay)!)) {
            mCell.labDate.layer.borderColor = (pubClass.ColorHEX(dictColor["blue"]!)).CGColor
            mCell.labDate.layer.backgroundColor = (pubClass.ColorHEX(dictColor["blue"]!)).CGColor
        }
        
        return mCell
    }
    
    /**
    * #mark: CollectionView delegate
    * CollectionView, 點取 Cell
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 取得點取的 txtDate 是否有文字, ex. '23'
        let dictBlock: Dictionary<String, AnyObject> = aryBlockData[indexPath.section][indexPath.row]
        let strDay = dictBlock["txtDay"] as! String
        
        if (strDay == "") {
            return
        }
        
        currYYMM["DD"] = String(format: "%02d", Int(strDay)!)
        
        self.initViewField()
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, Cell width
     */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: (collectionView.bounds.size.width/7) - 1.0, height: (collectionView.bounds.size.height/6) - 0.5)
    }
    
    /**
     * #mark: UITableView Delegate
     * 當日預約資料: 回傳指定的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryReservDataDay.count
    }
    
    /**
     * #mark: UITableView Delegate
     * 當日預約資料: UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryReservDataDay.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = aryReservDataDay[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellReservList", forIndexPath: indexPath) as! ReservListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * 當日預約資料: UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    /**
     * act, 點取 前月/次月 button, 需設定 restorationId
     */
    @IBAction func actMMChange(sender: UIButton) {
        let strident = sender.restorationIdentifier
        var YY: Int = Int(currYYMM["YY"]!)!
        var MM: Int = Int(currYYMM["MM"]!)!
        
        if (strident == "btnCalendarNext") {
            if (lastYYMM == (currYYMM["YY"]! + currYYMM["MM"]!)) {
                return
            }
            
            MM++
            if (MM > 12) {
                MM = 1; YY++;
            }
            
            positionReservData++
        }
        else {
            if (firstYYMM == (currYYMM["YY"]! + currYYMM["MM"]!)) {
                return
            }
            
            MM--;
            if (MM < 1) {
                MM = 12; YY--;
            }
            
            positionReservData--
        }
        
        currYYMM["YY"] = String(YY)
        currYYMM["MM"] = String(format:"%02d", MM)
        currYYMM["DD"] = "01"
        
        self.initViewField()
    }
    
    /**
     * act, 點取 '今日' button
     */
    @IBAction func actToday(sender: UIBarButtonItem) {
        currYYMM["YY"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 4)
        currYYMM["MM"] = pubClass.subStr(strToday, strFrom: 4, strEnd: 6)
        currYYMM["DD"] = pubClass.subStr(strToday, strFrom: 6, strEnd: 8)
        positionReservData = positionToday
        
        self.initViewField()
    }
    
    /**
     * act, 點取 '新增預約' button
     */
    @IBAction func actAddReserv(sender: UIButton) {
        
    }

    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}