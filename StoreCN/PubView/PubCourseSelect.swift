//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 公用 class, 會員已購買的療程訂單資料列表
 */
class PubCourseSelect: UITableViewController {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // parent 設定, 療程訂單資料, 療程DB, 全部會員資料
    var aryCourseData: Array<Dictionary<String, AnyObject>> = []
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var strToday = ""
    var currIndexPath: NSIndexPath?
    
    // 其他參數設定
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        labNoData.alpha = 0.0
        
        if (self.aryCourseData.count < 1) {
            self.labNoData.alpha = 1.0
        }
    }
    
    /**
     * View WiiAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        if let tmpIndexPath = currIndexPath {
            tableData.reloadData()
            tableData.selectRowAtIndexPath(tmpIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
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
        }
    }
    
}