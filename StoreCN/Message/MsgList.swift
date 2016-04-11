//
// TableView
//

import UIKit
import Foundation

/**
 * 訊息發布列表
 */
class MsgList: UIViewController, PubClassDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    private var pubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday: String!
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
        
        // TableCell 自動調整高度
        tableData.estimatedRowHeight = 100.0
        tableData.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * viewDidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload) {
            bolReload = false
            reConnHTTP()
        }
    }
    
    /**
     * #mark: PubClassDelegate
     */
    func PageNeedReload(needReload: Bool) {
        bolReload = true
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 檢查是否有資料
        if let aryTmp = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryData = aryTmp
        }
        
        if (aryData.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("nodata"), withHandler: {})
            return
        }
        
        // tableview reload
        tableData.reloadData()
        if let tmpIndexPath = currIndexPath {
            tableData.selectRowAtIndexPath(tmpIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
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
        mParam["page"] = "message"
        mParam["act"] = "message_getdata"
        
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellMsgList", forIndexPath: indexPath) as! MsgListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        
        self.performSegueWithIdentifier("MsgEdit", sender: aryData[indexPath.row])
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            pubClass.popConfirm(self, aryMsg: [self.pubClass.getLang("systemwarring"), self.pubClass.getLang("delconfirmmsg")], withHandlerYes: {
                
                // 產生 http post data, http 連線儲存後跳離
                var dictParm: Dictionary<String, String> = [:]
                dictParm["acc"] = self.pubClass.getAppDelgVal("V_USRACC") as? String
                dictParm["psd"] = self.pubClass.getAppDelgVal("V_USRPSD") as? String
                dictParm["page"] = "message"
                dictParm["act"] = "message_senddata"
                
                var dictArg0: Dictionary<String, AnyObject> = [:]
                dictArg0["del"] = "Y"
                dictArg0["mode"] = "edit"
                dictArg0["index_id"] = self.aryData[indexPath.row]["index_id"] as! String
                
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
                        // 回傳失敗跳離
                        var bolRS = false
                        if let bolTmp = dictRS["result"] as? Bool {
                            bolRS = bolTmp
                        }
                        
                        if (bolRS != true) {
                            self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
                            return
                        }
                        
                        // array data, tableData row 移除
                        self.aryData.removeAtIndex(indexPath.row)
                        self.tableData.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                        
                        return
                    }
                )
                
                }, withHandlerNo: {return})
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "MsgAdd") {
            let mVC = segue.destinationViewController as! MsgAdd
            mVC.strToday = strToday
            mVC.delegate = self
            
            return
        }
        
        if (segue.identifier == "MsgEdit") {
            let mVC = segue.destinationViewController as! MsgEdit
            mVC.strToday = strToday
            mVC.dictData = sender as! Dictionary<String, AnyObject>
            mVC.delegate = self
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '新增' button
     */
    @IBAction func actAdd(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("MsgAdd", sender: nil)
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}