//
// TableView, PurchaseListDetailDelegate
//

import UIKit
import Foundation

/**
 * !TODO! table cell 點取有權限
 *
 * 商品管理 - 進貨列表
 */
class PurchaseList: UIViewController, PubClassDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // table data 設定
    private var aryData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    private var currIndexPath: NSIndexPath?
    private var bolReload = true // 頁面是否需要 http reload
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.chkHaveData()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            bolReload = false
            reConnHTTP()
        }
    }
    
    /**
    * 檢查是否有資料
    */
    private func chkHaveData() {
        // 檢查資料
        if let tmpData = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryData = tmpData
        }
        
        // 檢查是否有資料
        if (aryData.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("nodata"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
        
        // tableview reload
        tableData.reloadData()
        if let tmpIndexPath = currIndexPath {
            tableData.selectRowAtIndexPath(tmpIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "purchase"
        mParam["act"] = "purchase_listdata"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤顯示錯誤訊息
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("nodata")
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
            
            if let today = dictData["today"] as? String {
                if (today.characters.count == 14) {
                    self.strToday = today
                }
            }
            
            self.dictAllData = dictData
            self.chkHaveData()
        })
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
        return aryData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryData.count < 1) {
            return UITableViewCell()
        }
        
        // 產生 Item data
        let ditItem = aryData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPurchaseList", forIndexPath: indexPath) as! PurchaseListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        
        self.performSegueWithIdentifier("PurchaseListDetail", sender: aryData[indexPath.row])
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // 有退貨資料不能刪除
            if let _ = self.aryData[indexPath.row]["return"] as? Array<AnyObject> {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("purchasee_cantdelpurchasemsg"))
                
                return
            }
            
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            pubClass.popConfirm(self, aryMsg: [self.pubClass.getLang("systemwarring"), self.pubClass.getLang("purchase_delwarringmsg")], withHandlerYes: {

                // 產生 http post data, http 連線儲存後跳離
                var dictParm: Dictionary<String, String> = [:]
                dictParm["acc"] = self.pubClass.getAppDelgVal("V_USRACC") as? String
                dictParm["psd"] = self.pubClass.getAppDelgVal("V_USRPSD") as? String
                dictParm["page"] = "purchase"
                dictParm["act"] = "purchase_editsave"
                
                var dictArg0: Dictionary<String, AnyObject> = [:]
                dictArg0["del_flag"] = "Y"
                dictArg0["invo_id"] = self.aryData[indexPath.row]["id"] as! String
                
                do {
                    let jobjData = try
                        NSJSONSerialization.dataWithJSONObject(dictArg0, options: NSJSONWritingOptions(rawValue: 0))
                    let jsonString = NSString(data: jobjData, encoding: NSUTF8StringEncoding)! as String
                    
                    dictParm["arg0"] = jsonString
                } catch {
                    self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_data"))
                    
                    return
                }
                
                self.pubClass.HTTPConn(self, ConnParm: dictParm,
                    callBack: { (dictRS: Dictionary<String, AnyObject>) in
                        // 回傳 page reload
                        let strMsg = (dictRS["result"] as! Bool != true) ? self.pubClass.getLang("err_trylatermsg") : self.pubClass.getLang("purchase_returndatadelcomplete")
                        
                        self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                            self.currIndexPath = NSIndexPath(forRow: -1, inSection: 0)
                            self.reConnHTTP()
                        })
                    }
                )
                
                }, withHandlerNo: {return})
        }
    }
    
    
    /**
     * #mark: PurchaseListDetailDelegate Delegate
     * 設定上層 class page 是否需要 reload
     */
    func PageNeedReload(needReload: Bool) {
        bolReload = needReload
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 進貨明細主頁面
        if (strIdent == "PurchaseListDetail") {
            let mVC = segue.destinationViewController as! PurchaseListDetail
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}