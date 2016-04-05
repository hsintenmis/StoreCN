//
// Container
//

import UIKit
import Foundation

/**
 * 療程預約, 新增頁面
 */
class CourseReservAdd: UIViewController, PickerDateTimeDelegate, CourseMemberListDelegate {
    
    // @IBOutlet
    @IBOutlet weak var labMember: UILabel!
    @IBOutlet weak var edDate: UITextField!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labOdrsId: UILabel!
    @IBOutlet weak var segmCourse: UISegmentedControl!
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var btnMember: UIButton!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""  // 前頁面傳入選擇的日期
    var aryCourse: Array<Dictionary<String, AnyObject>> = []  // 預設療程
    var aryMember: Array<Dictionary<String, AnyObject>> = []  // 全部會員資料
    
    // table view 相關參數, 2個 section
    private var aryTableData: Array<Array<Dictionary<String, AnyObject>>> = []  // table data sourse
    private var currIndexCourse: NSIndexPath?  // table cell, 目前選擇的療程
    
    // 其他參數
    private var currIndexMember: NSIndexPath? // 已選擇的會員
    private var mPickerDateTime: PickerDateTime!  // 預約日期 Picker
    private var dictRequest: Dictionary<String, String> = [:]  // 資料儲存 request 參數

    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMember.layer.cornerRadius = 5
        
        // 預約時間預設值
        dictRequest["time"] = strToday + "1200"
        
        /* Picker 設定 */
        // 預約日期
        var dictPickParm: Dictionary<String, AnyObject> = [:] // 日期 picker
        dictPickParm["def"] = dictRequest["time"]
        dictPickParm["min"] = "201501010001"
        dictPickParm["max"] = "203512312359"
        
        mPickerDateTime = PickerDateTime(withUIField: edDate, withDefMaxMin: [dictPickParm["def"] as! String, dictPickParm["max"] as! String, dictPickParm["min"] as! String], NavyBarTitle: pubClass.getLang("courseresver_selecttime"))
        mPickerDateTime.delegate = self
        
        // TableCell autoheight
        tableList.estimatedRowHeight = 150.0
        tableList.rowHeight = UITableViewAutomaticDimension
        
        // 重設與重整 table data source
        resetTableData()
    }
    
    /**
    * 重設與重整 table data source
    */
    private func resetTableData() {
        aryTableData.append(aryCourse)
        aryTableData.append([])
        tableList.reloadData()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "CourseMemberList") {
            let mVC = segue.destinationViewController as! CourseMemberList
            mVC.aryMember = aryMember
            mVC.currIndexPath = currIndexMember
            mVC.delegate = self
            
            return
        }

        return
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
        currIndexCourse = indexPath
        let intSect = indexPath.section
        let ditItem = aryTableData[intSect][indexPath.row]
        
        
        dictRequest["course_id"] = ditItem["pdid"] as? String
        dictRequest["pdid"] = ditItem["pdid"] as? String
        
        if let strTmp = ditItem["invo_id"] as? String {
            dictRequest["odrs_id"] = strTmp
        } else {
            dictRequest["odrs_id"] = ""
        }
        
        labCourse.text = ditItem["pdname"] as? String
        labOdrsId.text = dictRequest["odrs_id"]
    }

    /**
     * #mark: UITableView Delegate
     * Section 標題
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let strTitle = (section == 0) ? "defcourse" : "memberbuycourse"
        return pubClass.getLang("courseresver_" + strTitle)
    }
    
    func MemberSelected(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        currIndexMember = MemberindexPath
        labMember.text = MemberData["membername"] as? String
        dictRequest["membername"] = MemberData["membername"] as? String
        dictRequest["memberid"] = MemberData["memberid"] as? String
        
        // 該會員是否有購買療程
        aryTableData.removeAtIndex(1)
        if let dictTmp = MemberData["odrs"] as? Array<Dictionary<String, AnyObject>> {
            aryTableData.append(dictTmp)
        } else {
            aryTableData.append([])
        }
        
        // 頁面資料重整，相關 Request 資料重設
        dictRequest["course_id"] = ""  // 療程商品編號
        dictRequest["pdid"] = "" // 療程商品編號
        dictRequest["odrs_id"] = "" // 已經購買療程的 invo_id
        
        tableList.reloadData()
        segmCourse.selectedSegmentIndex = 0
        labCourse.text = ""
        labOdrsId.text = ""
    }
    
    /**
     * #mark: PickerDateTimeDelegate
     * 日期時間選擇完成，執行相關程序
     */
    func doneSelectDateTime(strDateTime: String) {
        dictRequest["time"] = strDateTime
    }
    
    /**
     * act, 點取 '選擇療程' Segmented, tableView 移動到指定 section
     */
    @IBAction func actSelCourse(sender: UISegmentedControl) {
        let mIndexPath = NSIndexPath(forRow: NSNotFound, inSection: sender.selectedSegmentIndex)
        tableList.scrollToRowAtIndexPath(mIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}