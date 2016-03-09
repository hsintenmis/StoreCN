//
// TableView
//

import UIKit
import Foundation

/**
 * 每日收入，選擇月份列出該月份每天的資料列表
 */
class AnalyDataDaily: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var colviewYYMM: UICollectionView!
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labDate: UILabel!
    
    @IBOutlet weak var labIncomePd: UILabel!
    @IBOutlet weak var labIncomeCourse: UILabel!
    @IBOutlet weak var labTotPrice: UILabel!
    @IBOutlet weak var labTotCustPrice: UILabel!
    @IBOutlet weak var labTotReturnPrice: UILabel!
    @IBOutlet weak var labIncome: UILabel!
    
    // common property
    private var pubClass: PubClass!
    
    // public, parent
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strToday: String!
    
    // 其他參數設定
    private var aryYYMM: Array<Dictionary<String, AnyObject>>!
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    private var indexPathYYMM: NSIndexPath!  // 目前 YYMM array data position
    private var currYYMM: String!  // 目前選擇的 yymm, ex. '201601'
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        indexPathYYMM = NSIndexPath(forRow: 0, inSection: 0)
        aryYYMM = dictAllData["data"] as! Array<Dictionary<String, AnyObject>>
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadPage()
    }
    
    /**
     * 頁面重整
     */
    private func reloadPage() {
        // 設定目前的 collectionView data source
        let dictYYMM = aryYYMM[indexPathYYMM.row]
        currYYMM = dictYYMM["yymm"] as! String
        labDate.text = pubClass.subStr(currYYMM, strFrom: 0, strEnd: 4) + " " + pubClass.getLang("mm_" + pubClass.subStr(currYYMM, strFrom: 4, strEnd: 6))
        colviewYYMM.reloadData()
        
        // 設定目前的 table data source
        aryTableData = dictYYMM["data"] as! Array<Dictionary<String, AnyObject>>
        tableData.reloadData()
        
        // 欄位資料設定
        if let _ = dictYYMM["totIncome"] as? String {
            labIncomePd.text = dictYYMM["totPdPrice"] as? String
            labIncomeCourse.text = dictYYMM["totCoursePrice"] as? String
            labTotPrice.text = dictYYMM["totSellPrice"] as? String
            labTotCustPrice.text = dictYYMM["totcustprice"] as? String
            labTotReturnPrice.text = dictYYMM["totreturn"] as? String
            labIncome.text = dictYYMM["totIncome"] as? String
        }
    }
    
    /**
     * #mark: CollectionView, 設定 Sections
     */
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     * #mark: CollectionView, 設定 資料總數
     */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aryYYMM.count
    }
    
    /**
     * #mark: CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (aryYYMM.count < 1) {
            return UICollectionViewCell()
        }
        
        let mCell: PubYYMMColtCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellAnalyDataDailyColt", forIndexPath: indexPath) as! PubYYMMColtCell
        
        let position = indexPath.row
        let strYYMM = aryYYMM[position]["yymm"] as! String
        let strMM = String(format: "%02d", Int(pubClass.subStr(strYYMM, strFrom: 4, strEnd: 6))!)
        
        mCell.labTitle.text = pubClass.subStr(strYYMM, strFrom: 0, strEnd: 4) + " " + pubClass.getLang("mm_" + strMM)
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        var strColor = "silver"
        
        if (indexPath == indexPathYYMM) {
            strColor = "blue"
        }
        mCell.backgroundColor = pubClass.ColorHEX(pubClass.dictColor[strColor])
        
        return mCell
    }
    
    /**
     * #mark: CollectionView, Cell click
     * 點取 collection cell
     */
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        indexPathYYMM = indexPath
        reloadPage()
    }

    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 row 的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryTableData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryTableData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryTableData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellAnalyDataDaily", forIndexPath: indexPath) as! AnalyDataDailyCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 顯示指定日期收入報表
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 產生 YYMMDD string
        let dictItem = aryTableData[indexPath.row] as Dictionary<String, AnyObject>
        let intDD = Int(dictItem["date"] as! String)!
        let strYMD = currYYMM + String(format: "%02d", intDD)
        
        self.performSegueWithIdentifier("AnalyDataDailyDetail", sender: strYMD)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AnalyDataDailyDetail") {
            let mVC = segue.destinationViewController as! AnalyDataDailyDetail
            mVC.strYYMMDD = sender as! String
            
            return
        }
        
        return
    }
    
}