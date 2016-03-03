//
// CollectionView, TableView
//

import UIKit
import Foundation

/**
 * 營養師績效列表
 */
class StaffBenefit: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var colviewYYMM: UICollectionView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    private var pubClass: PubClass!
    
    // 本頁面需要的全部資料, parent 設定
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryYYMM: Array<Dictionary<String, AnyObject>> = []
    private var dictYYMM: Dictionary<String, AnyObject> = [:]  // 目前的 YYMM dict
    
    // table data 設定
    private var aryTableData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    private var strToday = ""
    private var indexPathYYMM: NSIndexPath!  // 目前 YYMM array data position
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        
        // 參數設定
        labNoData.alpha = 0.0
        indexPathYYMM = NSIndexPath(forRow: 0, inSection: 0)
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidAppear(animated: Bool) {
        reConnHTTP()
    }
    
    /**
     * 檢查是否有資料
     */
    private func relaodPage() {
        // 設定 tableview datasource
        if let aryTmp = aryYYMM[indexPathYYMM.row]["staff"] as? Array<Dictionary<String, AnyObject>> {
            aryTableData = aryTmp
            labNoData.alpha = 0.0
        } else {
            aryTableData = []
            labNoData.alpha = 1.0
        }
        
        tableData.reloadData()
        colviewYYMM.reloadData()
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "staff"
        mParam["act"] = "staff_benefit"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            self.strToday = dictData["today"] as! String
            self.dictAllData = dictData
            
            // 設定全部的 YYMM array data, 有錯跳離本頁面
            if let aryTmp = self.dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
                self.aryYYMM = aryTmp
            }

            if (self.aryYYMM.count < 1) {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            }
            
            // 重整頁面
            self.relaodPage()
        })
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
        
        let mCell: StaffBenefitColtViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellStaffBenefitColtView", forIndexPath: indexPath) as! StaffBenefitColtViewCell
        
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
        relaodPage()
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
     * 回傳指定 section 的數量
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellStaffBenefit", forIndexPath: indexPath) as! StaffBenefitCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("StaffBenefitDetail", sender: aryTableData[indexPath.row])
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "StaffBenefitDetail") {
            let mVC = segue.destinationViewController as! StaffBenefitDetail
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }

        return
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}