//
// UITableViewController
//

import UIKit
import Foundation

/**
 * 公用 class, 會員已購買的療程訂單資料列表
 */
class PubCourseSelect: UITableViewController, PubClassDelegate {
    // delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 傳入
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 療程訂單資料, 療程DB, 全部會員資料
    private var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    private var strToday = ""
    private var currIndexPath: NSIndexPath?
    
    // 其他參數
    private var bolReload = false
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 本頁面資料設定
        //self.chkHaveData()
    }
    
    /**
     * viewDidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        /*
        if (bolReload == true) {
            bolReload = false
            chkHaveData()
        }
        */
        
        
        chkHaveData()
    }
    
    /**
     * #mark: PubClassDelegate
     * Page 重整
     */
    func PageNeedReload(needReload: Bool) {
        bolReload = needReload
        delegate?.PageNeedReload!(needReload)
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 檢查是否有資料
        var hasErr = false
        
        if let aryTmp = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = aryTmp
        } else {
            hasErr = true
        }
        
        if let aryTmp = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseData = aryTmp
        } else {
            hasErr = true
        }
        
        if let aryTmp = dictAllData["course"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseDB = aryTmp
        } else {
            hasErr = true
        }
        
        if (hasErr == true) {
            labNoData.alpha = 1.0
            return
        } else {
            labNoData.alpha = 0.0
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
        mParam["page"] = "cardmanage"
        mParam["act"] = "cardmanage_getdata"
        
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
            self.chkHaveData()
            
        })
    }

    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryCourseData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryCourseData.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = aryCourseData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellPubCourseSelect", forIndexPath: indexPath) as! PubCourseSelectCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        let dictSender = aryCourseData[indexPath.row] 
        self.performSegueWithIdentifier("PubCourseSaleEdit", sender: dictSender)
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 已購買療程編輯頁面
        if (strIdent == "PubCourseSaleEdit") {
            let mVC = segue.destinationViewController as! PubCourseSaleEdit
            mVC.strToday = strToday
            mVC.aryCourseDB = aryCourseDB
            mVC.aryMember = aryMember
            mVC.dictSaleData = sender as! Dictionary<String, AnyObject>
            mVC.delegate = self
        }
    }
    
}