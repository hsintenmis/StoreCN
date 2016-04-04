//
// UITableViewController
//

import UIKit
import Foundation

/**
 * 指定會員的療程訂單列表, 顯示於'會員管理'的'療程紀錄'
 */
class CourseList: UITableViewController, PubClassDelegate {
    // delegate, 會員主頁面資料變動
    var delegate = MemberHttpDataDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 傳入
    var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var strMemberId: String!
    var strToday: String!
    
    // 其他參數設定
    private var mMemberHttpData: MemberHttpData!  // http 連線取得會員全部資料
    private var currIndexPath: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        mMemberHttpData = MemberHttpData(VC: self)
        labNoData.alpha = 0.0
        
        if (self.aryCourseData.count < 1) {
            self.labNoData.alpha = 1.0
        }
    }
    
    /**
     * #mark: PubClassDelegate,
     * 重新 http 連線取得資料，本頁面 table reload, 通知 parent 資料變動
     */
    func PageNeedReload(needReload: Bool) {
        if (needReload != true) {
            return
        }
        
        // http 連線取得會員全部相關資料
        mMemberHttpData.connGetData(strMemberId, connCallBack: {
            (dictAllMemberData) -> Void in
            
            // 回傳資料失敗
            if (dictAllMemberData["result"] as! Bool != true) {
                var errMsg = dictAllMemberData["err"] as! String
                if (errMsg.characters.count < 1)  {
                    errMsg = self.pubClass.getLang("err_systemmaintain")
                }
                
                self.pubClass.popIsee(self, Msg: errMsg)
                
                return
            }
            
            // 回傳資料成功，本頁面 table reload
            self.strToday = dictAllMemberData["today"] as! String
            
            if let aryTmp = dictAllMemberData["course"] as? Array<Dictionary<String, AnyObject>> {
                self.aryCourseData = aryTmp                
                self.labNoData.alpha = 0.0
            } else {
                self.aryCourseData = []
                self.labNoData.alpha = 1.0
            }
            
            self.tableData.reloadData()
            if (self.currIndexPath != nil) {
                self.tableData.selectRowAtIndexPath(self.currIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            }
            
            // 通知上層須要更新資料
            self.delegate?.UpDateMemberAllData(dictAllMemberData)
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
        self.performSegueWithIdentifier("CourseEdit", sender: dictSender)
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