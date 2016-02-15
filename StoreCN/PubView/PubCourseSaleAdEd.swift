//
// UITableViewController, data selected delegate, 直接從 storyboard 設定
//

import UIKit
import Foundation

/**
 * 療程銷售 資料新增/編輯 公用 class
 */
class PubCourseSaleAdEd: UITableViewController {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var swchCardType: UISegmentedControl!
    
    @IBOutlet weak var swchActSoqibed: UISwitch!
    
    @IBOutlet weak var stepCardType: UIStepper!
    @IBOutlet weak var labCardTypeCount: UILabel!
    
    @IBOutlet weak var labMember: UILabel!
    @IBOutlet weak var labCourseName: UILabel!
    @IBOutlet weak var labExpire: UILabel!
    @IBOutlet weak var labFee: UILabel!
    
    @IBOutlet weak var labInvoId: UILabel!
    @IBOutlet weak var labSdate: UILabel!
    
    @IBOutlet weak var txtSugst: UITextView!
    @IBOutlet weak var txtStepPd: UITextView!
    
    @IBOutlet var swchSoqbed: [UISegmentedControl]!  // switch group
    @IBOutlet weak var edSoqibedS00: UITextField!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // soqibed H01..., 遠紅外線設備代碼
    let aryHotDevCode = ["H00","H01","H02","H10","H11","H12"]
    let aryHotDevMinVal = [0, 15, 30, 45, 60]
    
    // 公用參數設定
    var strMode = "add"
    var strToday = ""
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    var dictData: Dictionary<String, AnyObject> = [:]
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數

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
     * public, child class 調用, 設定'訂購人'資料，
     */
    func selectMember(dictMember: Dictionary<String, AnyObject>) {
        labMember.text = dictMember["membername"] as? String
        dictData["member"] = dictMember
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
        edSoqibedS00.text = dictData["S00"] as? String
        
        // soqibed 模式，數值變動, UISegmentedControl
        for swchDev in swchSoqbed {
            // 取得欄位名稱, ex. 'H00'
            let strIdent = swchDev.restorationIdentifier  // ex. 'DevH00'
            let strKey = strIdent!.stringByReplacingOccurrencesOfString("Dev", withString: "", range: nil)
            
            // 取得數值後，根據對應順序設定到 UISegmentedControl
            let intVal = Int(dictData[strKey] as! String)
            
            for (loopi = 0; loopi < aryHotDevMinVal.count; loopi++) {
                if (intVal == aryHotDevMinVal[loopi]) {
                    swchDev.selectedSegmentIndex = loopi
                    break
                }
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
        if (strIdent == "cellCoursSaleMemberSel") {
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
            self.performSegueWithIdentifier("CoursSaleSugst", sender: nil)
            return
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員選擇
        if (strIdent == "CourseSaleMemberSel") {
            let mVC = segue.destinationViewController as! CoursSaleMemberSel
            mVC.parentClass = self
            mVC.strToday = strToday
            mVC.aryMember = aryMember
            
            return
        }
        
        // 療程DB list 選擇
        if (strIdent == "CourseSaleCourseSel") {
            let mVC = segue.destinationViewController as! CourseSaleCourseSel
            mVC.parentClass = self
            mVC.strToday = strToday
            mVC.aryCourseDB = aryCourseDB
            
            return
        }
        
        // 療程建議說明
        if (strIdent == "CoursSaleSugst") {
            let mVC = segue.destinationViewController as! CoursSaleSugst
            mVC.parentClass = self
            
            return
        }
    }
    
    /**
     * 回傳本頁面全部欄位資料
     */
    func getData()->Dictionary<String, AnyObject> {
        dictData["type"] = "add"
        
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

