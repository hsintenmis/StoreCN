//
// 
//

import UIKit
import Foundation

/**
 * 全部會員已購買療程列表, 服務管理 => 療程管理
 */
class CourseListAll: UIViewController, PubClassDelegate {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labNodata: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 本頁面 TableVuew 需要的資料，全部會員訂購的療程
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    private var strToday = ""
    private var currIndexPath: NSIndexPath?
    
    // SearchBar 相關
    private var searchActive : Bool = false
    private var aryNewCourseData: Array<Dictionary<String, AnyObject>> = []  // 搜尋結果的 array
    
    // 其他參數
    private var bolReload = true
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        labNodata.alpha = 0.0
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
     * #mark: PubClassDelegate,
     * 重新 http 連線取得資料，本頁面 table reload, 通知 parent 資料變動
     */
    func PageNeedReload(needReload: Bool) {
        if (needReload == true) {
            reConnHTTP()
            return
        }
    }
    
    /**
     * 檢查是否有資料
     */
    private func chkHaveData() {
        // 全部會員 array data
        if let aryTmp = dictAllData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = aryTmp
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            return
        }
        
        // 療程 DB 列表
        if let aryTmp = dictAllData["course"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseDB = aryTmp
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
            return
        }
        
        // 已購買的療程列表
        if let aryTmp = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseData = aryTmp
            
            // table data soursce 加入原始的 position
            for i in (0..<self.aryCourseData.count) {
                self.aryCourseData[i]["position"] = i
            }
        } else {
            labNodata.alpha = 1.0
            aryCourseData = []
        }
        
        self.aryNewCourseData = self.aryCourseData
        
        // tableview reload
        tableList.reloadData()
        if let tmpIndexPath = currIndexPath {
            tableList.selectRowAtIndexPath(tmpIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
        
        return
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
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定sectiuon的 Row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryNewCourseData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryNewCourseData.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = aryNewCourseData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseList", forIndexPath: indexPath) as! CourseListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // 取得正確的 indexPath
        let mRow = aryNewCourseData[indexPath.row]["position"] as! Int
        self.currIndexPath = NSIndexPath(forRow: mRow, inSection: 0)
        
        // 設定點取的 dict data
        let dictSender = aryNewCourseData[indexPath.row]
        self.performSegueWithIdentifier("CourseEdit", sender: dictSender)
    }
    
    /**
     * #Mark Delegate: 系統的 UITableView
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出確認視窗
            pubClass.popConfirm(self, aryMsg: [pubClass.getLang("systemwarring"), pubClass.getLang("coursesale_delalertmsg")], withHandlerYes: {self.delProc(indexPath)}, withHandlerNo: {})
        }
        
        return
    }
    
    /**
     * 刪除程序, 刪除會員已購買的療程
     */
    private func delProc(indexPath: NSIndexPath!) {
        searchBar.text = ""
        let strInvoId = aryNewCourseData[indexPath.row]["invo_id"] as! String
        
        // http 連線參數設定, 產生 'arg0' JSON string
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "cardmanage"
        dictParm["act"] = "cardmanage_deldata"
        dictParm["arg0"] = strInvoId
        
        // HTTP 開始連線, 連線完成 aryMember 移除資料
        self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictHTTPSRS: Dictionary<String, AnyObject>)->Void in
            
            let bolRS = dictHTTPSRS["result"] as! Bool
            var strMsg = self.pubClass.getLang("err_trylatermsg")
            
            if (bolRS == true) {
                let dictData = dictHTTPSRS["data"]!["content"]!
                strMsg = self.pubClass.getLang("datadelcompleted")
                
                if let strTmp = dictData!["msg"] as? String {
                    if (strTmp != "") {
                        strMsg = strTmp
                    }
                }
                
                // 刪除成功與否，重新 http reload page
                self.pubClass.popIsee(self, Msg: strMsg, withHandler: {
                    self.currIndexPath = nil
                    self.reConnHTTP()
                })
                
                return
            }
            
            self.pubClass.popIsee(self, Msg: strMsg)
        })
        
        return
    }
    
    /**
     * #mark: UISearchBar Delegate
     */
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    /**
     * #mark: UISearchBar Delegate
     * 搜尋字元改變時
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (aryCourseData.count < 1) {
            searchActive = false;
            return
        }
        
        // 沒有輸入字元
        if (searchText.isEmpty) {
            searchActive = false;
            searchBar.resignFirstResponder()
            
            aryNewCourseData = aryCourseData
            self.tableList.reloadData()
            
            return
        }

        // 比對字元, 比對欄位: 姓名, 訂單編號, 療程名稱
        let aryField = ["membername", "invo_id", "pdname"]
        
        aryNewCourseData = aryCourseData.filter({ (dictItem: Dictionary<String, AnyObject>) -> Bool in
            
            for strField in aryField {
                if let strWord: String = dictItem[strField] as? String {
                    if strWord.lowercaseString.rangeOfString(searchText) != nil {
                        return true
                    }
                }
            }
            
            return false
        })
        
        if( aryNewCourseData.count == 0 ){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableList.reloadData()
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
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}