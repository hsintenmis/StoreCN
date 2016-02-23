//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * protocol, PubCourseSelect Delegate
 */
protocol PubCourseDataSelectDelegate {
    /**
     * Table Cell 點取，點取指定資料，實作點取後相關程序
     */
    func CourseDataSelected(CourseData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath)
}

/**
 * 療程DB 資料選擇 公用 class
 */
class PubCourseSelect: UITableViewController {
    var delegate = PubCourseDataSelectDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labNoData: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // parent 設定, 會員已購買的療程訂單資料,
    var aryCourseData: Array<Dictionary<String, AnyObject>> = []
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
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
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
        delegate?.CourseDataSelected(CourseData: aryCourseData[indexPath.row], indexPath: indexPath)
    }
    
}

