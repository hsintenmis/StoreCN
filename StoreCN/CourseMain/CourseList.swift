//
// UITableViewController
//

import UIKit
import Foundation

/**
 * 指定會員的療程訂單列表, 顯示於'會員管理'的'療程紀錄'
 */
class CourseList: UITableViewController, PubClassDelegate {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 傳入
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strMemberId: String!
    var strToday: String!
    
    // 療程訂單資料, 療程DB, 全部會員資料
    private var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    private var currIndexPath: NSIndexPath?
    
    // 其他參數
    private var bolReload = true
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        //super.viewDidLoad()
        labNoData.alpha = 1.0
    }
    
    /**
     * viewDidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload == true) {
            bolReload = false
            reConnHTTP()
        }
    }
    
    /**
     * #mark: PubClassDelegate
     * 頁面重整 flag 通知
     */
    func PageNeedReload(needReload: Bool) {
        if (needReload == true) {
            reConnHTTP()
        }
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 檢查是否有資料
        var hasErr = false
        
        if let aryTmp = dictAllData["datamember"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = aryTmp
        } else {
            hasErr = true
        }
        
        // 已購買的療程列表
        if let aryTmp = dictAllData["course"] as? Array<Dictionary<String, AnyObject>> {
            
            // 指定 '會員 ID', 重新整理 array data，若有
            aryCourseData = []
            for dictTmp in aryTmp {
                if (dictTmp["memberid"] as? String == strMemberId) {
                    aryCourseData.append(dictTmp)
                }
            }
            
            if (aryCourseData.count < 1) {
                hasErr = true
            }
        } else {
            hasErr = true
        }
        
        // 療程 DB 列表
        if let aryTmp = dictAllData["datacourse"] as? Array<Dictionary<String, AnyObject>> {
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
        
        bolReload = false
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // http 參數設定, 連線設定，判別 parent '療程管理列表' or '會員管理的療程列表'
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "cardmanage"
        mParam["act"] = "cardmanage_getdata"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤, 停留本頁面
            if (dictRS["result"] as! Bool != true) {
                self.labNoData.alpha = 1.0
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
     * Section 的數量
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    /**
     * #mark: UITableView Delegate
     * 回傳指定sectiuon的 Row 數量
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
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseList", forIndexPath: indexPath) as! CourseListCell
        
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
        if (strIdent == "CourseEdit") {
            let mVC = segue.destinationViewController as! CourseEdit
            mVC.strToday = strToday
            mVC.aryCourseDB = aryCourseDB
            mVC.aryMember = aryMember
            mVC.dictSaleData = sender as! Dictionary<String, AnyObject>
            mVC.delegate = self
        }
    }
    
}