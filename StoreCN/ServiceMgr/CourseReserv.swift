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
    
    @IBOutlet weak var labMM: UILabel!
    @IBOutlet weak var labYY: UILabel!
    
    // common property
    private let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var mCalendarCellData: CalendarCellData!
    private var currYYMM: Dictionary<String, String> = [:]  // 目前選擇的 YYMM
    private var aryBlockData: Array<Array<Dictionary<String, AnyObject>>> = []
    
    // 本月曆的起始 YYMM
    private let firstYYMM = "201503"
    private var lastYYMM = "202512"
    
    // 顏色
    private let dictColor = ["white":"FFFFFF", "red":"FFCCCC", "gray":"C0C0C0", "silver":"F0F0F0", "blue":"66CCFF", "black":"000000", "green":"99CC33"]
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數

        // 取得 Calendar cell 需要的全部資料
        currYYMM = ["YY":pubClass.subStr(strToday, strFrom: 0, strEnd: 4), "MM":pubClass.subStr(strToday, strFrom: 4, strEnd: 6), "DD":pubClass.subStr(strToday, strFrom: 6, strEnd: 8)]
        mCalendarCellData = CalendarCellData(DataSource: nil)
        
        // 初始與顯示頁面資料
        initViewField()
        
        // test
        /*
        coltviewCalendar.layer.borderWidth = 1
        coltviewCalendar.layer.borderColor = (pubClass.ColorHEX(dictColor["gray"]!)).CGColor
        */
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
        aryBlockData = mCalendarCellData.getAllData(currYYMM)
        coltviewCalendar.reloadData()
        labYY.text = currYYMM["YY"]
        labMM.text = pubClass.getLang("mm_" + currYYMM["MM"]!)
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
        mCell.labDate.text = dictBlock["txtDay"] as? String
        
        // 樣式/外觀/顏色
        mCell.labDate.layer.borderWidth = 1
        mCell.labDate.layer.cornerRadius = 25 / 2
        mCell.labDate.layer.borderColor = (pubClass.ColorHEX(dictColor["green"]!)).CGColor
        
        // 有資料的日期
        
        // 目前選擇的日期
        
        return mCell
    }
    
    /**
     * #mark: CollectionView delegate
     * CollectionView, Cell width
     */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: (collectionView.bounds.size.width/7) - 1.0, height: (collectionView.bounds.size.height/6) - 0.5)
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
        }
        else {
            if (firstYYMM == (currYYMM["YY"]! + currYYMM["MM"]!)) {
                return
            }
            
            MM--;
            if (MM < 1) {
                MM = 12; YY--;
            }
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
        
        self.initViewField()
    }

    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}