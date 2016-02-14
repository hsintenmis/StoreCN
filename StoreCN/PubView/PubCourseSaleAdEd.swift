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
    @IBOutlet weak var swchCardType: UISegmentedControl!
    @IBOutlet weak var stepCardType: UIStepper!
    @IBOutlet weak var labCardTypeCount: UILabel!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 公用參數設定
    var strMode = "add"
    var strToday = ""
    var aryCourseDB: Array<Dictionary<String, AnyObject>> = []
    var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        print(aryCourseDB)
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
     * 回傳本頁面全部欄位資料
     */
    func getData()->Dictionary<String, AnyObject> {
        var dictData: Dictionary<String, AnyObject> = [:]
        
        print(labCardTypeCount)
        
        dictData["type"] = "add"
        //dictData["count"] = labCardTypeCount.text

        return dictData
    }
    
    /**
    * act, Stepper, 卡片型態數值 count 增減
    */
    @IBAction func actCardTypeCount(sender: UIStepper) {
        labCardTypeCount.text = "\(Int(stepCardType.value))"
    }
}

