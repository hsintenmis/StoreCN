//
// Container 轉入, Static TableView 主頁面
//

import UIKit
import Foundation

/**
 * 會員預約療程編輯主頁面
 */
class CourseReservEditCont: UITableViewController, PickerDateTimeDelegate, CourseMemberListDelegate, MemberAllCourseListDelegate {
    
    // @IBOutlet
    @IBOutlet weak var edDate: UITextField!
    
    @IBOutlet weak var lab_used_time: UILabel!
    @IBOutlet weak var titleIsFinish: UILabel!
    @IBOutlet weak var titleIsCancel: UILabel!
    @IBOutlet weak var swchFinish: UISwitch!
    @IBOutlet weak var swchCancel: UISwitch!
    @IBOutlet weak var labMemberName: UILabel!
    @IBOutlet weak var labCourseName: UILabel!
    @IBOutlet weak var labOdrsId: UILabel!
    @IBOutlet weak var txtviewMemo: UITextView!
    @IBOutlet weak var btnCloseKB: UIButton!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var dictData: Dictionary<String, AnyObject> = [:]  // 預約的資料
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []  // 預設療程
    var aryCourseCust: Array<Dictionary<String, AnyObject>> = []  // 已購買療程
    var aryMember: Array<Dictionary<String, AnyObject>> = []  // 全部會員資料
    var strToday: String!
    
    // 其他參數
    private var allowFinish = true  // 是否可點取 switch btn 'finish'
    private var allowCancel = true  // 是否可點取 switch btn 'cancel'
    private var currIndexMember: NSIndexPath?  // 選擇的會員 indexpath
    private var currIndexCourse: NSIndexPath?  // 選擇的療程 indexpath
    
    private var mPickerDateTime: PickerDateTime!  // 預約日期 Picker
    private var dictRequest: Dictionary<String, String> = [:]  // 資料儲存 request 參數
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view field value 固定顯示預設值, 外觀樣式
        btnCloseKB.enabled = false

        txtviewMemo.layer.cornerRadius = 5
        txtviewMemo.layer.borderWidth = 1
        txtviewMemo.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtviewMemo.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
        
        // 目前會員的 indexPath
        for i in (0..<aryMember.count) {
            if ((aryMember[i]["memberid"] as! String) == dictData["memberid"] as! String ) {
                currIndexMember = NSIndexPath(forItem: i, inSection: 0)
                break
            }
        }
        
        // 預約時間預設值
        dictRequest["time"] = (dictData["yymm"] as! String) + (dictData["dd"] as! String) + (dictData["hh"] as! String) + (dictData["min"] as! String)
        edDate.text = pubClass.formatDateWithStr(dictRequest["time"], type: 14)
        
        /* Picker 設定 */
        // 預約日期
        var dictPickParm: Dictionary<String, AnyObject> = [:] // 日期 picker
        dictPickParm["def"] = dictRequest["time"]
        dictPickParm["min"] = "201501010001"
        dictPickParm["max"] = "203512312359"
        
        mPickerDateTime = PickerDateTime(withUIField: edDate, withDefMaxMin: [dictPickParm["def"] as! String, dictPickParm["max"] as! String, dictPickParm["min"] as! String], NavyBarTitle: pubClass.getLang("courseresver_selecttime"))
        mPickerDateTime.delegate = self
        
        // 初始/重設 本頁面 field value
        initViewField()
    }
    
    /**
    * 設定 '療程完成', '取消預約' switch btn 與相關 field
    */
    private func setStatSwitchBtn() {
        // 療程完成時間
        let strFinishTime = dictData["used_time"] as! String
        if (strFinishTime.characters.count > 0) {
            allowCancel = false
            lab_used_time.text = pubClass.formatDateWithStr(strFinishTime, type: 14)
            swchFinish.on = true
        } else {
            lab_used_time.text = ""
        }
        
        // 是否有療程訂單編號
        let strOdrsId = dictData["odrs_id"] as! String
        if (strOdrsId.characters.count < 1) {
            allowFinish = false
            labOdrsId.text = ""
        } else {
            labOdrsId.text = strOdrsId
        }
    }
    
    /**
    * 初始/重設 本頁面 field value
    */
    private func initViewField() {
        // 設定 '療程完成', '取消預約' switch btn 與相關 field
        setStatSwitchBtn()
        
        // labMemberName, labCourseName, txtviewMemo
        labMemberName.text = dictData["membername"] as? String
        labCourseName.text = dictData["coursename"] as? String
        txtviewMemo.text = dictData["memo"] as? String
        
        // '療程完成', '取消預約' switch btn 與相關 field
        let colorTrue = "303030"
        let colorFalse = "C0C0C0"
        
        if (allowFinish != true) {
            titleIsFinish.textColor = (pubClass.ColorHEX(colorFalse))
            swchFinish.enabled = false
            swchFinish.on = false
        } else {
            titleIsFinish.textColor = (pubClass.ColorHEX(colorTrue))
            swchFinish.enabled = true
        }
        
        if (allowCancel != true) {
            titleIsCancel.textColor = (pubClass.ColorHEX(colorFalse))
            swchCancel.enabled = false
            swchCancel.on = false
        } else {
            titleIsCancel.textColor = (pubClass.ColorHEX(colorTrue))
            swchCancel.enabled = true
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, sect1: 0=>會員, 1=>療程
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section != 1) {
            return
        }
        
        // 標示 '療程完成', 不能更改會員, 必須先取消 '療程完成'
        // 選擇會員 Cell
        if (indexPath.row == 0) {
            if (allowFinish == true) {
                pubClass.popIsee(self, Msg: pubClass.getLang("coursereserv_finishnochange"))
                return
            }
            
            self.performSegueWithIdentifier("CourseMemberList", sender: nil)
            return
        }
        
        // 選擇療程 Cell
        if (indexPath.row == 1) {
            if (allowFinish == true) {
                pubClass.popIsee(self, Msg: pubClass.getLang("coursereserv_finishnochange"))
                return
            }
            
            self.performSegueWithIdentifier("MemberAllCourseList", sender: nil)
            return
        }
    }
    
    /**
     * #mark: textViewDidBeginEditing
     * 建議療程輸入文字框，點取執行相關程序
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == edDate) {
            if (allowFinish == true) {
                textField.resignFirstResponder()
                pubClass.popIsee(self, Msg: pubClass.getLang("coursereserv_finishnochange"))
                return
            }
        }
    }
    
    /**
     * #mark: textViewDidBeginEditing
     * 建議療程輸入文字框，點取執行相關程序
     */
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == txtviewMemo) {
            // 顯示關閉鍵盤 btn
            btnCloseKB.enabled = true
        }
    }
    
    /**
     * #mark: CourseMemberListDelegate, 會員選擇完成
     * 部分欄位 value 需要重設
     */
    func MemberSelected(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        currIndexMember = MemberindexPath
        labMemberName.text = MemberData["membername"] as? String
        
        dictRequest["membername"] = MemberData["membername"] as? String
        dictRequest["memberid"] = MemberData["memberid"] as? String
        
        // 重設該會員的 '已購買療程' array data
        if let dictTmp = MemberData["odrs"] as? Array<Dictionary<String, AnyObject>> {
            aryCourseCust = dictTmp
        } else {
            aryCourseCust = []
        }
        
        // 頁面資料重整，相關 Request 資料重設
        dictRequest["course_id"] = ""  // 療程商品編號
        dictRequest["pdid"] = "" // 療程商品編號
        dictRequest["odrs_id"] = "" // 已經購買療程的 invo_id
        currIndexCourse = nil
        
        labCourseName.text = ""
        labOdrsId.text = ""
    }
    
    /**
     * #mark: CourseMemberListDelegate, 會員選擇完成
     * 部分欄位 value 需要重設
     */
    func CourseSelected(CourseData: Dictionary<String, AnyObject>, CourseIndexPath: NSIndexPath) {
        currIndexCourse = CourseIndexPath
        
        dictRequest["course_id"] = CourseData["pdid"] as? String
        dictRequest["pdid"] = CourseData["pdid"] as? String
        
        if let strTmp = CourseData["invo_id"] as? String {
            dictRequest["odrs_id"] = strTmp
        } else {
            dictRequest["odrs_id"] = ""
        }
        
        labCourseName.text = CourseData["pdname"] as? String
        labOdrsId.text = dictRequest["odrs_id"]
    }
    
    /**
     * #mark: PickerDateTimeDelegate
     * 日期時間選擇完成，執行相關程序
     */
    func doneSelectDateTime(strDateTime: String) {
        dictRequest["time"] = strDateTime
    }

    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員選擇
        if (strIdent == "CourseMemberList") {
            let mVC = segue.destinationViewController as! CourseMemberList
            mVC.delegate = self
            mVC.strToday = strToday
            mVC.aryMember = aryMember
            mVC.currIndexPath = currIndexMember
            
            return
        }
        
        // 療程選擇
        if (strIdent == "MemberAllCourseList") {
            let mVC = segue.destinationViewController as! MemberAllCourseList
            mVC.delegate = self
            mVC.aryCourseDB = aryCourseDB
            mVC.aryCourseCust = aryCourseCust
            
            return
        }
        
        return
    }
    
    /**
     * public, parent 調用，回傳本頁面全部欄位資料<BR>
     * 回傳整理好的 dict REQUEST 資料<BR>
     * 有錯誤回傳 nil
     */
    func getPageData() -> Dictionary<String, AnyObject>? {
        // 輸入資料檢查
        if (dictRequest["memberid"] == nil) {
            pubClass.popIsee(self, Msg: pubClass.getLang("coursereserv_err_member"))
            return nil
        }
        
        if (dictRequest["time"] == nil) {
            pubClass.popIsee(self, Msg: pubClass.getLang("coursereserv_err_time"))
            return nil
        }
        
        if (labCourseName.text?.characters.count < 1) {
            pubClass.popIsee(self, Msg: pubClass.getLang("coursereserv_err_course"))
            return nil
        }
        
        dictRequest["mode"] = "edit"
        
        print(dictRequest)
        
        return dictRequest
    }

    /**
     * act, '關閉鍵盤' btn,
     */
    @IBAction func actCloseKB(sender: UIButton) {
        btnCloseKB.enabled = false
        txtviewMemo.resignFirstResponder()
    }
    
    /**
     * Switch btn, 點取 '療程完成'
     */
    @IBAction func actFinish(sender: UISwitch) {
        if (sender.on == true) {
            swchCancel.on = false
        }
    }
    
    /**
     * Switch btn, 點取 '取消預約'
     */
    @IBAction func actCancel(sender: UISwitch) {
        if (sender.on == true) {
            swchFinish.on = false
        }
    }
    
    
}