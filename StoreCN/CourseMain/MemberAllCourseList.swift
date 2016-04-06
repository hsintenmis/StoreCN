//
// Dynamic Table, 2 section, different cell
//

import UIKit
import Foundation

/**
 * protocol, CourseMemberList Delegate
 */
protocol MemberAllCourseListDelegate {
    /**
     * 本頁面點取 '會員 Item'  parent 執行相關程序
     */
    func CourseSelected(CourseData: Dictionary<String, AnyObject>, CourseIndexPath: NSIndexPath)
}

/**
 * 會員預約療程編輯, 點取'選擇療程'轉入本頁面
 * 包含系統預設療程 與 會員已購買的療程
 */
class MemberAllCourseList: UIViewController {
    // delegate
    var delegate = MemberAllCourseListDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var segmCourse: UISegmentedControl!
    @IBOutlet weak var tableList: UITableView!
    
    // common property
    private let pubClass: PubClass = PubClass()

    // public, 本頁面需要的全部資料, parent 設定
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []  // 預設療程
    var aryCourseCust: Array<Dictionary<String, AnyObject>> = []  // 已購買療程
    
    // table view 相關參數, 2個 section
    private var aryTableData: Array<Array<Dictionary<String, AnyObject>>> = []  // table data sourse

    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 產生 table data source
        aryTableData.append(aryCourseDB)
        aryTableData.append(aryCourseCust)
        
        // TableCell autoheight
        tableList.estimatedRowHeight = 150.0
        tableList.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 的數量
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    /**
     * #mark: UITableView Delegate
     * 回傳指定sectiuon的 Row 數量
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return aryTableData[section].count
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 內容, 不同 cell 初始對應的 cell class
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let intSect = indexPath.section
        let arySection = aryTableData[intSect]
        
        if (arySection.count < 1) {
            return UITableViewCell()
        }
        
        let ditItem = arySection[indexPath.row]
        segmCourse.selectedSegmentIndex = intSect
        
        /* 預設療程, 使用 tableview Cell 預設樣式 */
        if (intSect == 0) {
            // 取得 Item data source, CellView
            let mCell = tableView.dequeueReusableCellWithIdentifier("cellCourseDefSel")!
            
            mCell.textLabel?.text = ditItem["pdname"] as? String
            mCell.detailTextLabel?.text = ditItem["pdid"] as? String
            
            return mCell
        }
        
        /* 預設療程, 使用 tableview Cell 預設樣式 */
        let mCell = tableView.dequeueReusableCellWithIdentifier("cellMemberCourseList", forIndexPath: indexPath) as! MemberCourseListCell
        
        mCell.initView(ditItem)
        
        return mCell
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let intSect = indexPath.section
        let ditItem = aryTableData[intSect][indexPath.row]
        
        self.dismissViewControllerAnimated(true, completion: {self.delegate?.CourseSelected(ditItem, CourseIndexPath: indexPath)})
    }
    
    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let strTitle = (section == 0) ? "defcourse" : "memberbuycourse"
        return pubClass.getLang("courseresver_" + strTitle)
    }

    /**
     * act, 點取 '選擇療程' Segmented, tableView 移動到指定 section
     */
    @IBAction func actSelCourse(sender: UISegmentedControl) {
        let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: sender.selectedSegmentIndex)
        tableList.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    /**
     * act, 點取 '取消' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}