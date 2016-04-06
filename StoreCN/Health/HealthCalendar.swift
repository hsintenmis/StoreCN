//
// CollectionView, Calendar 設定
//

import UIKit
import Foundation

/**
 * 健康管理, 月曆主頁面
 */
class HealthCalendar: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var coltviewCalendar: UICollectionView!
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labYY: UILabel!
    @IBOutlet weak var labMMDD: UILabel!
    @IBOutlet weak var btnToday: UIButton!
    
    // common property
    private let pubClass = PubClass()
    
    // public, parent 傳入
    var dictMember: Dictionary<String, AnyObject>!
    
    // 本頁面需要的全部資料
    private var strToday = ""
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    
    private var dictCalAllData: Dictionary<String, AnyObject> = [:] // 全部月曆的 datasource
    
    // table view 相關
    private var aryTestField: Array<String>!  // 全部健康項目的欄位 key
    private var dictTableData: Dictionary<String, Dictionary<String, String>> = [:]
    private var dictCurrDayData: Dictionary<String, String> = [:]  // dictCalAllData 指定的資料
    
    // 其他參數設定
    private var mHealthDataInit: HealthDataInit!  // 健康檢測資料初始
    private var bolReload = true
    
    // 本月曆的起始 YYMM
    private let firstYYMM = "201501"
    private var lastYYMM = "202512"
    
    // calendar 相關
    private var mCalendarCellData = CalendarCellData()
    private var currYYMMDD: Dictionary<String, String>!  // 目前選擇的 YYMMDD
    private var aryBlockData: Array<Array<Dictionary<String, AnyObject>>> = [] // 指定月份全部的 'block' 資料
    
    // 顏色
    private var dictColor: Dictionary<String, String>!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        // 固定初始參數
        super.viewDidLoad()
        
        dictColor = pubClass.dictColor
        
        mHealthDataInit = HealthDataInit()
        aryTestField = mHealthDataInit.D_HEALTHITEMKEY
        dictTableData = mHealthDataInit.GetAllTestData()

        btnToday.layer.cornerRadius = 5
        
        // TableCell autoheight
        tableList.estimatedRowHeight = 120.0
        tableList.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload == true) {
            bolReload = false
            reConnHTTP()
        }
    }
    
    /**
     * 檢查是否有資料與頁面重整
     */
    private func chkHaveData() {
        /*
        // 檢查是否有會員
        if let tmpData = dictAllData["member"] as? Dictionary<String, AnyObject> {
            dictMember = tmpData
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("errdata"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
        */
        
        // 設定月曆各個日期資料
        if let tmpData = dictAllData["data"] as? Dictionary<String, AnyObject> {
            dictCalAllData = tmpData
        }
        
        // 設定今天日期相關參數
        lastYYMM = pubClass.subStr(strToday, strFrom: 0, strEnd: 6)  // 最後一天
        currYYMMDD = ["YY":pubClass.subStr(strToday, strFrom: 0, strEnd: 4), "MM":pubClass.subStr(strToday, strFrom: 4, strEnd: 6), "DD":pubClass.subStr(strToday, strFrom: 6, strEnd: 8)]
        
        // 初始 VC view 內的 field
        initViewField()
    }
    
    /**
     * 初始/重整 VC view 內的 field
     */
    func initViewField() {
        // 取得指定月份資料
        let dictCalMM = self.transCalendarDictdata()
        
        // 設定 calendar data, 月份改變時處理
        aryBlockData = mCalendarCellData.getAllData(currYYMMDD, DataSource: dictCalMM)
        coltviewCalendar.reloadData()
        
        // 本頁面相關 field value 設定
        labYY.text = currYYMMDD["YY"]
        labMM.text = pubClass.getLang("mm_" + currYYMMDD["MM"]!)
        labMMDD.text = String(format: pubClass.getLang("FMT_MMDD"), Int(currYYMMDD["MM"]!)!, Int(currYYMMDD["DD"]!)!)
        
        // 重新設定 tableview
        getCurrDDTableDataSource()
        tableList.reloadData()
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // http 參數設定, 連線設定，判別 parent '療程管理列表' or '會員管理的療程列表'
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "health"
        mParam["act"] = "health_getdatamember"
        mParam["arg0"] = dictMember["memberid"] as? String
        
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離本頁
            if (dictRS["result"] as! Bool != true) {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            self.strToday = dictData["today"] as! String
            self.dictAllData = dictData
            self.chkHaveData()
        })
    }
    
    /**
     * 指定的月份，資料轉為 'CalendarCellData.getAllData()' 需要的 dict data
     */
    private func transCalendarDictdata() -> Dictionary<String, AnyObject>? {
        let strYYMM = "D_" + currYYMMDD["YY"]! + currYYMMDD["MM"]!
        var dictCalMM: Dictionary<String, AnyObject> = [:]
        var strYMD = ""
        
        for i in (1..<32) {
            strYMD = strYYMM + String(format: "%02d", i)
            if let dictTmp = dictCalAllData[strYMD] as? Dictionary<String, AnyObject> {
                dictCalMM["dd" + String(i)] = dictTmp
            }
        }
        
        return dictCalMM
    }
    
    /**
     * 從 'dictCalAllData' 取得指定 YMD 的 dict 資料， TableList 使用
     */
    private func getCurrDDTableDataSource() {
        let strYMD = "D_" + currYYMMDD["YY"]! + currYYMMDD["MM"]! + currYYMMDD["DD"]!
        
        if let dictTmp = dictCalAllData[strYMD] as? Dictionary<String, String> {
            dictCurrDayData = dictTmp
        } else {
            dictCurrDayData = [:]
        }
        
        // 產生健康項目對應的數值，名稱等..相關資料
        mHealthDataInit.setAllTestData(dictCurrDayData)
        dictTableData = mHealthDataInit.GetAllTestData()
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (aryBlockData.count > 0) ? 6 : 0
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (aryBlockData.count > 0) ? 7 : 0
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (aryBlockData.count < 1) {
            return UICollectionViewCell()
        }
        
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
        if (currYYMMDD["DD"] == String(format: "%02d", Int(strDay)!)) {
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
        
        currYYMMDD["DD"] = String(format: "%02d", Int(strDay)!)
        
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
     * 當日健康數值: 回傳指定的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryTestField.count
    }
    
    /**
     * #mark: UITableView Delegate
     * 當日健康數值: UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // 設定 cell 內容
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellHealthTestingVal", forIndexPath: indexPath) as! HealthTestingValCell
        
        let strKey = aryTestField[indexPath.row]
        var dictItem = dictTableData[strKey]!
        
        if (dictCurrDayData.count > 0) {
            dictItem["age"] = dictCurrDayData["age"]
            dictItem["gender"] = dictCurrDayData["gender"]
        }
        
        mCell.initView(dictItem, mPubClass: pubClass, strField: strKey)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * 當日健康數值: UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("HealthItemEdit", sender: indexPath)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "HealthItemEdit") {
            let strItemKey = (mHealthDataInit.D_HEALTHITEMKEY)[(sender as! NSIndexPath).row]
            let mVC = segue.destinationViewController as! HealthItemEdit

            mVC.strItemKey = strItemKey
            mVC.dictAllData = dictTableData
            mVC.dictCurrDate = currYYMMDD
            mVC.dictMember = dictMember as! Dictionary<String, String>
            
            return
        }
        
        if (strIdent == "MemberHealthWeb") {
            let mVC = segue.destinationViewController as! MemberHealthWeb

            mVC.strMemberId = dictMember["memberid"] as! String
            mVC.strMemberPsd = dictMember["psd"] as! String
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 前月/次月 button, 需設定 restorationId
     */
    @IBAction func actMMChange(sender: UIButton) {
        let strident = sender.restorationIdentifier
        var YY: Int = Int(currYYMMDD["YY"]!)!
        var MM: Int = Int(currYYMMDD["MM"]!)!
        
        if (strident == "btnCalendarNext") {
            if (lastYYMM == (currYYMMDD["YY"]! + currYYMMDD["MM"]!)) {
                return
            }
            
            MM += 1
            if (MM > 12) {
                MM = 1; YY += 1;
            }
        }
        else {
            if (firstYYMM == (currYYMMDD["YY"]! + currYYMMDD["MM"]!)) {
                return
            }
            
            MM -= 1;
            if (MM < 1) {
                MM = 12; YY -= 1;
            }
        }
        
        currYYMMDD["YY"] = String(YY)
        currYYMMDD["MM"] = String(format:"%02d", MM)
        currYYMMDD["DD"] = "01"
        
        self.initViewField()
    }
    
    /**
     * act, 點取 '今日' button
     */
    @IBAction func actToday(sender: UIButton) {
        currYYMMDD["YY"] = pubClass.subStr(strToday, strFrom: 0, strEnd: 4)
        currYYMMDD["MM"] = pubClass.subStr(strToday, strFrom: 4, strEnd: 6)
        currYYMMDD["DD"] = pubClass.subStr(strToday, strFrom: 6, strEnd: 8)
        
        self.initViewField()
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}