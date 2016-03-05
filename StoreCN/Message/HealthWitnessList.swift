//
// CollectionView, TableView
//

import UIKit
import Foundation

/**
 * 健康訊息列表
 */
class HealthWitnessList: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var colectView: UICollectionView!
    
    // common property
    private var pubClass: PubClass!
    
    // table data 設定
    private var dictAllData: Dictionary<String, AnyObject> = [:]  // http 回傳資料
    private var aryAllData: Array<Dictionary<String, AnyObject>> = []  // 全部 table 資料
    
    // 其他參數設定
    private var currPosition = 0  // 目前選單的 position
    private var bolReloadPage = true
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
    }

    override func viewDidAppear(animated: Bool) {
        if (bolReloadPage) {
            bolReloadPage = false
            reConnHTTP()
        }
    }
    
    /**
     * 檢查是否有資料
     */
    private func relaodPage() {
        colectView.reloadData()
        tableData.reloadData()
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "memberdata"
        mParam["act"] = "memberdata_getwitnessgroup"
        
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
            
            self.dictAllData = dictData
            
            // 設定全部的 YYMM array data, 有錯跳離本頁面
            if let aryTmp = self.dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
                self.aryAllData = aryTmp
            }
            
            if (self.aryAllData.count < 1) {
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
        return aryAllData.count
    }
    
    /**
     * #mark: CollectionView, 設定資料 Cell 的内容
     */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (aryAllData.count < 1) {
            return UICollectionViewCell()
        }
        
        let mCell: HealthWitnessListColtViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cellHealthWitnessListColtView", forIndexPath: indexPath) as! HealthWitnessListColtViewCell
        
        mCell.labTitle.text = aryAllData[indexPath.row]["dirname"] as? String
        
        // 樣式/外觀/顏色
        mCell.layer.cornerRadius = 2
        var strColor = "silver"
        
        if (indexPath.row == currPosition) {
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
        
        currPosition = indexPath.row
        relaodPage()
        
        let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: currPosition)
        tableData.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return aryAllData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定 section 的 Row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryAllData[section]["data"]!.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, 使用 tableview 預設
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryAllData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellHealthWitnessList")!
        let ditItem = aryAllData[indexPath.section]["data"]![indexPath.row] as! Dictionary<String, String>

        mCell.textLabel?.text = ditItem["title"]
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ditItem = aryAllData[indexPath.section]["data"]![indexPath.row] as! Dictionary<String, String>
        self.performSegueWithIdentifier("HealthWitnessDetail", sender: ditItem)
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let strTitle = aryAllData[section]["dirname"] as? String {
            return strTitle
        }
        
        return ""
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "HealthWitnessDetail") {
            let mVC = segue.destinationViewController as! HealthWitnessDetail
            mVC.dictData = sender as! Dictionary<String, String>
            
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