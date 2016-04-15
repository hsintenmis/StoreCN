//
//
//

import UIKit
import Foundation

/**
 * 療程使用記錄列表，由 'CourseAdEd' 轉入
 */
class CourseUseList: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, parent 設定, 本頁面 TableVuew 需要的資料
    var aryAllData: Array<Dictionary<String, AnyObject>> = []
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableCell 自動調整高度
        tableList.estimatedRowHeight = 100.0
        tableList.rowHeight = UITableViewAutomaticDimension
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
        return aryAllData.count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (aryAllData.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = aryAllData[indexPath.row] as Dictionary<String, AnyObject>
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseUseList", forIndexPath: indexPath) as! CourseUseListCell
        
        mCell.initView(ditItem, PubClass: pubClass)
        
        return mCell
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}