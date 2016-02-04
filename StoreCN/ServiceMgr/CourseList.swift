//
// TableView
//

import UIKit
import Foundation

/**
 * 療程管理，列表 + 刪除 功能
 */
class Courselist: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    var mVCtrl: UIViewController!
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // HTTP 回傳資料設定
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    var strToday = ""
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mVCtrl = self
        dictPref = pubClass.getPrefData()
        
        // 療程 TableList Cell 直接調用 Nib 檔案, 需在本 class 指定 cell height
        tableList.registerNib(UINib(nibName: "CourseListCell", bundle: nil), forCellReuseIdentifier: "cellCourseList")
        self.tableList.rowHeight = 120.0
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // HTTP 連線取得資料
        StartHTTPConn()
        
        dispatch_async(dispatch_get_main_queue(), {

        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * HTTP 連線取得資料
     */
    private func StartHTTPConn() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "cardmanage";
        dictParm["act"] = "cardmanage_getdata";
        
        // HTTP 開始連線
        pubClass.HTTPConn(mVCtrl, ConnParm: dictParm, callBack: HttpResponChk)
    }
    
    /**
     * HTTP 連線後取得連線結果
     * 資料 key name：data, course, member 型態為 Array<Dictionary<String, AnyObject>>
     */
    private func HttpResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            dispatch_async(dispatch_get_main_queue(), {
                self.pubClass.popIsee(self.mVCtrl, Msg: self.pubClass.getLang(dictRS["msg"] as? String), withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
            
            return
        }
        
        /* 解析正確的 http 回傳結果，執行後續動作 */
        let dictData = (dictRS["data"]!["content"]!)!

        strToday = dictData["today"] as! String
        
        // 設定資料, 若無會員或無已購買的療程，離開
        aryCourseDB = dictData["course"] as! Array<Dictionary<String, AnyObject>>
        
        var strErr = ""
        if let tmpData = dictData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseData = tmpData
        } else {
            strErr = pubClass.getLang("nodata")
        }
        
        if let tmpData = dictData["member"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        } else {
            strErr = pubClass.getLang("nomember")
        }
        
        if (strErr != "") {
            pubClass.popIsee(mVCtrl, Msg: strErr, withHandler: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            return
        }
        
        // 本頁面資料重整
        tableList.reloadData()
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return aryCourseData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        if (aryCourseData.count < 1) {
            return nil
        }
        
        let ditItem = aryCourseData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseList", forIndexPath: indexPath) as! CourseListCell
        
        mCell.initView(ditItem, PubClass: pubClass)

        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            
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

