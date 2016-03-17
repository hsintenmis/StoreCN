//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 療程銷售 資料新增/編輯 資料上傳, 公用 class
 */
class PubCourseSaleAdEd: UITableViewController, UITextFieldDelegate, UITextViewDelegate, CourseSaleMemberSelDelegate, CourseSaleCourseSelDelegate {
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet var swchSoqbed: [UISegmentedControl]!  // HotDev 6個 Segment
    @IBOutlet weak var edExpire: UITextField!
    @IBOutlet weak var edFee: UITextField!
    @IBOutlet weak var swchCardType: UISegmentedControl!
    @IBOutlet weak var swchActSoqibed: UISwitch!
    @IBOutlet weak var stepCardType: UIStepper!
    @IBOutlet weak var labCardTypeCount: UILabel!
    @IBOutlet weak var labMember: UILabel!
    @IBOutlet weak var labCourseName: UILabel!
    @IBOutlet weak var labInvoId: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var txtSugst: UITextView!
    @IBOutlet weak var txtStepPd: UITextView!

    @IBOutlet weak var labS00: UILabel!
    @IBOutlet weak var sliderS00: UISlider!
    @IBOutlet weak var labTypeUnit: UILabel!
    @IBOutlet weak var btnCloseKB: UIButton!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // soqibed H01..., 遠紅外線/搖擺機 設備代碼
    let aryHotDevCode = ["H00","H01","H02","H10","H11","H12"]
    let aryHotDevMinsVal = [0, 15, 30, 45, 60]
    let aryS00DevMinsVal = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30]
    
    // public, parent 設定參數
    var strMode = "add"
    var strToday = ""
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var dictSaleData: Dictionary<String, AnyObject> = [:]  // 編輯模式，原始欄位資料 dict data
    
    // 點取欄位，彈出虛擬鍵盤視窗
    private var mPickerExpire: PickerDate!
    private var mPickerS00: PickerNumber!
    
    // 其他參數設定
    private var indexPathMember: NSIndexPath?
    private var indexPathPd: NSIndexPath?
    private var aryFixUnit = ["次", "个月"]
    private var dictPickParm: Dictionary<String, AnyObject> = [:] // 日期 picker
    private var dictRequest: Dictionary<String, AnyObject> = [:]  // http 存檔傳遞參數
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        edFee.delegate = self
        txtSugst.delegate = self
        btnCloseKB.alpha = 0.0
        
        /* Picker 設定 */
        // 到期日欄位
        dictPickParm["expire_def"] = "20160101"
        dictPickParm["expire_min"] = "20150101"
        dictPickParm["expire_max"] = "20251231"
        
        mPickerExpire = PickerDate(withUIField: edExpire, PubClass: pubClass, withDefMaxMin: [dictPickParm["expire_def"] as! String, dictPickParm["expire_max"] as! String, dictPickParm["expire_min"] as! String], NavyBarTitle: pubClass.getLang("course_expiredate"))
        
        // 設備 S00, 設定分鐘數
        sliderS00.maximumValue = Float(aryS00DevMinsVal.count - 1)
        sliderS00.minimumValue = 0
        
        // textView 外觀樣式
        txtSugst.layer.cornerRadius = 5
        txtSugst.layer.borderWidth = 1
        txtSugst.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtSugst.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
        
        txtStepPd.layer.cornerRadius = 5
        txtStepPd.layer.borderWidth = 1
        txtStepPd.layer.borderColor = (pubClass.ColorHEX(pubClass.dictColor["gray"]!)).CGColor
        txtStepPd.layer.backgroundColor = (pubClass.ColorHEX(pubClass.dictColor["white"]!)).CGColor
        
        // 編輯模式，設定 field value
        if (self.strMode == "edit") {
            self.editModeInit()
        }
    }
    
    /**
     * 編輯模式，設定 field value
     */
    private func editModeInit() {
        labInvoId.text = dictSaleData["odrs_id"] as? String
        labSdate.text = pubClass.formatDateWithStr(dictSaleData["sdate"] as! String, type: 14)
        edFee.text = dictSaleData["price"] as? String

        dictRequest["expire"] = dictSaleData["sdate"] as? String
        
        // 會員, id 對應 'indexPathMember'
        let mMemberId = dictSaleData["memberid"] as! String
        labMember.text = dictSaleData["membername"] as? String
        
        for (var i=0; i < aryMember.count; i++) {
            if (mMemberId == aryMember[i]["memberid"] as! String) {
                indexPathMember = NSIndexPath(forItem: i, inSection: 0)
            }
        }
        
        // 購買的療程, id 對應 'indexPathMember'
        let mPdid = dictSaleData["pdid"] as! String
        labCourseName.text = dictSaleData["pdname"] as? String
        
        for (var i=0; i < aryCourseDB.count; i++) {
            if (mPdid == aryCourseDB[i]["id"] as! String) {
                indexPathPd = NSIndexPath(forItem: i, inSection: 0)
                break
            }
        }
        
        // SOQI Bed 資料
        if let dictTmp = dictSaleData["soqibed"] as? Dictionary<String, String> {
            self.CourseDBDataSelected(CourseData: dictTmp, indexPath: indexPathPd!)
        } else {
            swchActSoqibed.on = false
        }
        
        labCourseName.text = aryCourseDB[indexPathPd!.row]["name"] as? String
        
        // card 療程型態
        swchCardType.selectedSegmentIndex = ((dictSaleData["card_type"] as! String) == "T") ? 0 : 1
        labCardTypeCount.text = dictSaleData["card_times"] as? String
        labTypeUnit.text = ((dictSaleData["card_type"] as! String) == "T") ? aryFixUnit[0] : aryFixUnit[1]
        
        // 次數 + - stepper
        stepCardType.value = Double(dictSaleData["card_times"] as! String)!
        
        // 到期日預設值
        dictPickParm["expire_def"] = pubClass.subStr((dictSaleData["end_date"] as! String), strFrom: 0, strEnd: 8)
        edExpire.text = pubClass.formatDateWithStr(dictSaleData["end_date"] as! String, type: 8)
        mPickerExpire = PickerDate(withUIField: edExpire, PubClass: pubClass, withDefMaxMin: [dictPickParm["expire_def"] as! String, dictPickParm["expire_max"] as! String, dictPickParm["expire_min"] as! String], NavyBarTitle: pubClass.getLang("course_expiredate"))
        
        // 療程建議說明文字
        txtSugst.text = dictSaleData["card_msg"] as! String
        
        // 療程步驟文字
        txtStepPd.text = aryCourseDB[(indexPathPd?.row)!]["steppd"] as! String
    }
    
    /**
     * public, child class 調用, 設定'療程建議說明' textView 文字資料
     */
    func setCourseSugstTxt(strTxt: String) {
        txtSugst.text = strTxt
    }
    
    /**
    * #mark: UITextFieldDelegate, 點取 'return'
    */
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    /**
     * #mark: CourseSaleCourseSelDelegate,
     * 建議工程(療程DB)，點取指定資料，實作點取後相關程序
     */
    func CourseDBDataSelected(CourseData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        
        indexPathPd = indexPath
        
        // 建議工程名稱, 疗程步骤与产品使用
        labCourseName.text = dictData["name"] as? String
        txtStepPd.text = dictData["steppd"] as? String
        labS00.text = dictData["S00"] as? String
        
        // soqibed 模式，數值變動, UISegmentedControl
        for swchDev in swchSoqbed {
            // 取得欄位名稱, ex. 'H00'
            let strIdent = swchDev.restorationIdentifier  // ex. 'DevH00'
            let strKey = strIdent!.stringByReplacingOccurrencesOfString("Dev", withString: "", range: nil)
            
            // 取得數值後，根據對應順序設定到 UISegmentedControl
            let intVal = Int(dictData[strKey] as! String)
            
            for (var loopi = 0; loopi < aryHotDevMinsVal.count; loopi++) {
                if (intVal == aryHotDevMinsVal[loopi]) {
                    swchDev.selectedSegmentIndex = loopi
                    break
                }
            }
        }
        
        //  soqibed 模式, S00 slider 變動
        for (var loopi = 0; loopi < aryS00DevMinsVal.count; loopi++) {
            let intVal = Int(dictData["S00"] as! String)
            if (intVal == aryS00DevMinsVal[loopi]) {
                sliderS00.value = Float(loopi)
                break
            }
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 取得點取 cell 的 Identifier, 執行 segue 跳轉
        let strIdent = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        // 會員選擇
        if (strIdent == "cellCourseSaleMemberSel") {
            self.performSegueWithIdentifier("CourseSaleMemberSel", sender: nil)
            return
        }
        
        // 療程DB list 選擇
        if (strIdent == "cellCourseSaleCourseSel") {
            self.performSegueWithIdentifier("CourseSaleCourseSel", sender: nil)
            return
        }
    }
    
    /**
    * #mark: CourseSaleMemberSelDelegate, 會員列表，點取會員執行相關程序
    */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        labMember.text = MemberData["membername"] as? String
        dictRequest["memberid"] = MemberData["memberid"] as? String
        
        dictSaleData["member"] = MemberData
        indexPathMember = MemberindexPath
    }
    
    /**
     * #mark: textViewDidBeginEditing
     * 建議療程輸入文字框，點取執行相關程序
     */
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == txtSugst) {
            // 顯示關閉鍵盤 btn
            btnCloseKB.alpha = 1.0
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員選擇
        if (strIdent == "CourseSaleMemberSel") {
            let mVC = segue.destinationViewController as! CourseSaleMemberSel
            mVC.delegate = self
            mVC.strToday = strToday
            mVC.aryMember = aryMember
            mVC.currIndexPath = indexPathMember
            
            return
        }
        
        // 療程 DB list 選擇
        if (strIdent == "CourseSaleCourseSel") {
            let mVC = segue.destinationViewController as! CourseSaleCourseSel
            mVC.delegate = self
            mVC.strToday = strToday
            mVC.aryCourseDB = aryCourseDB
            mVC.currIndexPath = indexPathPd
            
            return
        }
        
        // 療程建議說明
        if (strIdent == "CourseSaleSugst") {
            let mVC = segue.destinationViewController as! CourseSaleSugst
            mVC.parentClass = self
            
            return
        }
    }
    
    /**
     * act, Segmented, 包卡包月 change
     */
    @IBAction func actCardType(sender: UISegmentedControl) {
        labTypeUnit.text = aryFixUnit[sender.selectedSegmentIndex]
    }
    
    /**
     * act, Slider, S00 分鐘數變動
     */
    @IBAction func actS00(sender: UISlider) {
        let currentValue = aryS00DevMinsVal[Int(sender.value)]
        labS00.text = "\(currentValue)"
    }
    
    /**
     * public, parent 調用，本頁面全部欄位資料上傳儲存<BR>
     * 回傳整理好的 dict REQUEST 資料<BR>
     * @return: dict, 'rs'=>Bool, 'data'=>dict data, 'msg'=>"" or msg
     */
    func saveData() -> Dictionary<String, AnyObject>! {
        var dictResult: Dictionary<String, AnyObject> = [:]
        dictResult["rs"] = false
        dictResult["data"] = [:]
        dictResult["msg"] = pubClass.getLang("err_trylatermsg")
        
        // 欄位值檢查
        var errMsg = ""
        
        if (labMember.text?.characters.count < 1) {
           errMsg = "coursesale_err_membername"
        }
        else if (labCourseName.text?.characters.count < 1) {
            errMsg = "coursesale_err_coursename"
        }
        else if (edExpire.text?.characters.count < 1) {
            errMsg = "coursesale_err_coursexpiredate"
        }
        else if (edFee.text?.characters.count < 1) {
            errMsg = "coursesale_err_fee"
        }
        
        if (errMsg != "") {
            dictResult["msg"] = pubClass.getLang(errMsg)
            return dictResult
        }
        
        // 產生回傳 dict data
        if (strMode == "edit") {
            dictRequest["odrsid"] = dictSaleData["odrs_id"] as? String
        }
        
        dictRequest["price"] = edFee.text
        dictRequest["membername"] = labMember.text
        dictRequest["coursename"] = labCourseName.text
        dictRequest["S00"] = labS00.text
        dictRequest["machmsg"] = txtSugst.text
        
        dictRequest["memberid"] = aryMember[indexPathMember!.row]["memberid"] as? String
        dictRequest["courseid"] = aryCourseDB[indexPathPd!.row]["id"] as? String
        dictRequest["type"] = (swchCardType.selectedSegmentIndex == 0) ? "T" : "M"
        dictRequest["times"] = labCardTypeCount.text
        dictRequest["expire"] = mPickerExpire.getStrDate()
        
        // SOQIBED hothouse 裝置時間, 是否啟用
        for swchDev in swchSoqbed {
            // 取得欄位名稱, ex. 'H00'
            let strIdent = swchDev.restorationIdentifier  // ex. 'DevH00'
            let strDevKey = strIdent!.stringByReplacingOccurrencesOfString("Dev", withString: "", range: nil)
            dictRequest[strDevKey] = String((swchDev.selectedSegmentIndex) * 15)
        }
        
        dictRequest["soqibed"] = (swchActSoqibed.on) ? "Y" : "N"
        
        // 回傳資料
        dictResult["rs"] = true
        dictResult["msg"] = ""
        
        return dictResult
    }
    
    /**
     * act, '關閉鍵盤' btn,
     */
    @IBAction func actCloseKB(sender: UIButton) {
        btnCloseKB.alpha = 0.0
        txtSugst.resignFirstResponder()
    }
    
    /**
    * act, '重新填寫' btn, 療程建議說明
    */
    @IBAction func actAddNewSugst(sender: UIButton) {
        // 療程建議說明編輯頁面
        self.performSegueWithIdentifier("CourseSaleSugst", sender: nil)
    }
    
    /**
    * act, Stepper, 卡片型態數值 count 增減
    */
    @IBAction func actCardTypeCount(sender: UIStepper) {
        if (Int(stepCardType.value) == 0) {
            stepCardType.value = 1.0
        }
        
        labCardTypeCount.text = "\(Int(stepCardType.value))"
        dictSaleData["count"] = labCardTypeCount.text
    }
    
}