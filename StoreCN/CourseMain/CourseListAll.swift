//
// 
//

import UIKit
import Foundation

/**
 * 全部會員已購買療程列表, 服務管理 => 療程管理
 */
class CourseListAll: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var labNodata: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 本頁面 TableVuew 需要的資料，全部會員訂購的療程
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    private var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    private var strToday = ""
    private var currIndexPath: NSIndexPath?
    
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

        } else {
            labNodata.alpha = 1.0
        }
        
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
        return aryCourseData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        let dictSender = aryCourseData[indexPath.row]
        self.performSegueWithIdentifier("CourseSaleEdit", sender: dictSender)
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
        }
    }
    
    /**
     * act, 點取 '主選單' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}