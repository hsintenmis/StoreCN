//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 療程銷售 資料新增/編輯 資料上傳, 公用 class
 */
class PubCourseSaleAdEd: UITableViewController, UITextFieldDelegate, CourseSaleMemberSelDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet var swchSoqbed: [UISegmentedControl]!  // switch group
    
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
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // soqibed H01..., 遠紅外線/搖擺機 設備代碼
    let aryHotDevCode = ["H00","H01","H02","H10","H11","H12"]
    let aryHotDevMinsVal = [0, 15, 30, 45, 60]
    let aryS00DevMinsVal = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30]
    
    // 由parent設定參數
    var strMode = "add"
    var strToday = ""
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var dictData: Dictionary<String, AnyObject> = [:]
    
    // 點取欄位，彈出虛擬鍵盤視窗
    private var mPickerExpire: PickerDate!
    private var mPickerS00: PickerNumber!
    
    // 其他參數設定
    private var indexPathMember: NSIndexPath?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        edFee.delegate = self
        
        /* Picker 設定 */
        // 到期日欄位
        var dictPickParm: Dictionary<String, AnyObject> = [:]
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
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
        
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {
        
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
     * public, child class 調用, 
     * 選擇建議工程後，soqibed模式/疗程步骤与产品使用 變動
     */
    func selectCourseDB(dictData: Dictionary<String, AnyObject>) {
        var loopi = 0;
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
            
            for (loopi = 0; loopi < aryHotDevMinsVal.count; loopi++) {
                if (intVal == aryHotDevMinsVal[loopi]) {
                    swchDev.selectedSegmentIndex = loopi
                    break
                }
            }
        }
        
        //  soqibed 模式, S00 slider 變動
        for (loopi = 0; loopi < aryS00DevMinsVal.count; loopi++) {
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
        
        // 療程建議說明
        if (strIdent == "cellCoursSaleSugst") {
            self.performSegueWithIdentifier("CourseSaleSugst", sender: nil)
            return
        }
    }
    
    /**
    * #mark: CourseSaleMemberSelDelegate, 會員列表，點取會員執行相關程序
    */
    func MemberSeltPageDone(MemberData: Dictionary<String, AnyObject>, MemberindexPath: NSIndexPath) {
        labMember.text = MemberData["membername"] as? String
        dictData["member"] = MemberData
        indexPathMember = MemberindexPath
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
            mVC.parentClass = self
            mVC.strToday = strToday
            mVC.aryCourseDB = aryCourseDB
            
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
        labTypeUnit.text = (sender.selectedSegmentIndex == 0) ? "次" : "个月"
    }
    
    /**
     * act, Slider, S00 分鐘數變動
     */
    @IBAction func actS00(sender: UISlider) {
        let currentValue = aryS00DevMinsVal[Int(sender.value)]
        labS00.text = "\(currentValue)"
    }
    
    /**
     * 本頁面全部欄位資料上傳儲存
     */
    func saveData()->Dictionary<String, AnyObject> {
        // 欄位值檢查
        
        return dictData
    }
    
    /**
    * act, Stepper, 卡片型態數值 count 增減
    */
    @IBAction func actCardTypeCount(sender: UIStepper) {
        labCardTypeCount.text = "\(Int(stepCardType.value))"
        dictData["count"] = labCardTypeCount.text
    }
}

