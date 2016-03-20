//
// Container
//

import UIKit
import Foundation

/**
 * 療程預約, 新增頁面
 */
class CourseReservAdd: UIViewController, CourseReservMemberSelDelegate, PickerDateTimeDelegate {
    
    // @IBOutlet
    @IBOutlet weak var labMember: UILabel!
    @IBOutlet weak var edDate: UITextField!
    @IBOutlet weak var labCourse: UILabel!
    @IBOutlet weak var labOdrsId: UILabel!
    @IBOutlet weak var segmCourse: UISegmentedControl!
    @IBOutlet weak var tableList: UITableView!
    
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
        
        // table data source
        aryTableData.append(aryCourse)
        aryTableData.append([])
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "CourseReservAddMemberSel") {
            let mVC = segue.destinationViewController as! CourseReservMemberSel
            mVC.aryMember = aryMember
            mVC.currIndexPath = currIndexMember
            mVC.delegate = self
            return
        }

        return
    }
    
    /**
    * #mark: CourseReservMemberSelDelegate
    * 會員列表選擇會員完成，執行相關程序
    */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        currIndexMember = MemberindexPath
        labMember.text = MemberData["membername"] as? String
        dictRequest["membername"] = MemberData["membername"] as? String
        dictRequest["memberid"] = MemberData["memberid"] as? String
        
        // 該會員是否有購買療程
        
    }
    
    /**
     * #mark: PickerDateTimeDelegate
     * 日期時間選擇完成，執行相關程序
     */
    func doneSelectDateTime(strDateTime: String) {
        dictRequest["time"] = strDateTime
    }
    
    /**
     * act, 點取 '選擇療程' Segmented
     */
    @IBAction func actSelCourse(sender: UISegmentedControl) {
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