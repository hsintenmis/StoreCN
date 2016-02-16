//
// UITableViewController,
//

import UIKit
import Foundation

/**
 * 療程銷售, 建議工程(療程DB) 選擇, 從'PubCourseSaleAdEd' 導入
 */
class CourseSaleCourseSel: UIViewController {
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // Table DataSource, 全部的療程 DB 資料, parent 設定
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    var parentClass: PubCourseSaleAdEd!
    var strToday = ""
    private var newIndexPath: NSIndexPath!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        newIndexPath = NSIndexPath(forRow: 0, inSection: 0)

    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
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
        newIndexPath = indexPath
        
        // parent 執行相關程序
        self.dismissViewControllerAnimated(true, completion: {self.parentClass.selectCourseDB(self.aryCourseDB[indexPath.row])})
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}