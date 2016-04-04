//
// UITableViewController,
//

import UIKit
import Foundation

/**
 * protocol, CourseDBList Delegate
 */
 protocol CourseDBListDelegate {
    /**
     * 預設建議工程(療程DB)，點取指定資料，實作點取後相關程序
     */
    func CourseDBSelected(CourseData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath)
 }

/**
 * 療程銷售, 預設建議工程(療程DB)列表
 */
class CourseDBList: UIViewController {
    // delegate
    var delegate = CourseDBListDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // Table DataSource, 全部的療程 DB 資料, parent 設定
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var currIndexPath: NSIndexPath?
    var strToday = ""
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // viewWillAppear
    override func viewWillAppear(animated: Bool) {
        if currIndexPath != nil {
           tableData.selectRowAtIndexPath(currIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定的數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryCourseDB.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容使用內建的格式
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryCourseDB.count < 1) {
            return UITableViewCell()
        }
        
        // 取得 Item data source, CellView
        let ditItem = aryCourseDB[indexPath.row]
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseSaleCourseSel")!
        
        mCell.textLabel?.text = ditItem["name"] as? String
        mCell.detailTextLabel?.text = ditItem["id"] as? String
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.CourseDBSelected(CourseData: aryCourseDB[indexPath.row], indexPath: indexPath)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}