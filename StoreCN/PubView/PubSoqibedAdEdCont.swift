//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * SOQIBED 編輯主頁面
 * <P>
 * 會員使用模式資料, 新增/編輯刪除<BR>
 * 各個裝置(H01, H02..)都需要設定預設值
 * <P>
 * 資料產生方式:<BR>
 * 1. MEAD檢測結果產生<br>
 * 2. 購買療程<br>
 * 3. 自行輸入
 */
class PubSoqibedAdEdCont: UITableViewController {

    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var edTitle: UITextField!
    @IBOutlet var swchSoqbed: [UISegmentedControl]!  // HotDev 6個 Segment
    @IBOutlet weak var labS00: UILabel!
    @IBOutlet weak var sliderS00: UISlider!
    @IBOutlet weak var labRecord: UILabel!
 
    // common property
    private let pubClass = PubClass()
    
    // public, paent 設定
    var dictAllData: Dictionary<String, AnyObject> = [:]
    var strMode: String! // 目前頁面模式, 'add' or 'edit'
    
    // soqibed H01..., 遠紅外線/搖擺機 設備代碼
    let aryHotDevCode = PubClass().aryHotDevCode
    let aryHotDevMinsVal = PubClass().aryHotDevMinsVal
    let aryS00DevMinsVal = PubClass().aryS00DevMinsVal
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設備 S00, 設定分鐘數
        sliderS00.maximumValue = Float(aryS00DevMinsVal.count - 1)
        sliderS00.minimumValue = 0
        
        // TableCell 自動調整高度
        tableList.estimatedRowHeight = 80.0
        tableList.rowHeight = UITableViewAutomaticDimension
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewWillAppear(animated: Bool) {
        self.initView()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        tableList.reloadData()
    }
    
    /**
    * View filed 資料初始/設定
    */
    private func initView() {
        edTitle.text = dictAllData["title"] as? String
        labS00.text = dictAllData["S00"] as? String
        
        // hothouse設備 UISegmentedControl
        for swchDev in swchSoqbed {
            // 取得欄位名稱, ex. 'H00'
            let strIdent = swchDev.restorationIdentifier  // ex. 'DevH00'
            let strKey = strIdent!.stringByReplacingOccurrencesOfString("Dev1", withString: "", range: nil)
            
            // 取得數值後，根據對應順序設定到 UISegmentedControl
            let intVal = Int(dictAllData[strKey] as! String)
            
            for loopi in (0..<aryHotDevMinsVal.count) {
                if (intVal == aryHotDevMinsVal[loopi]) {
                    swchDev.selectedSegmentIndex = loopi
                    break
                }
            }
        }
        
        //  soqibed 模式, S00 slider 變動
        for loopi in (0..<aryS00DevMinsVal.count) {
            let intVal = Int(dictAllData["S00"] as! String)
            if (intVal == aryS00DevMinsVal[loopi]) {
                sliderS00.value = Float(loopi)
                break
            }
        }
        
        // 處理使用記錄
        var strRecords = ""
        if let aryItems = dictAllData["times"] as? Array<Dictionary<String, String>> {
            for dictItem in aryItems {
                strRecords += pubClass.formatDateWithStr(dictItem["sdate"], type: 14) + "\n"
            }
        }
        
        labRecord.text = strRecords
        
        // 設備 S00 slider 預設值
        for loopi in (0..<aryS00DevMinsVal.count) {
            let intVal = Int(dictAllData["S00"] as! String)
            if (intVal == aryS00DevMinsVal[loopi]) {
                sliderS00.value = Float(loopi)
                break
            }
        }
    }
    
    /**
     * #mark: UITextFieldDelegate
     * 虛擬鍵盤: 'Return' key 型態與動作
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 關閉鍵盤
        if textField == edTitle {
            textField.resignFirstResponder()
            return true
        }
        
        return true
    }
    
    /**
     * act, Slider, S00 分鐘數變動
     */
    @IBAction func actS00(sender: UISlider) {
        let currentValue = aryS00DevMinsVal[Int(sender.value)]
        labS00.text = "\(currentValue)"
    }

    /**
     * act, 點取 '刪除' button, 刪除完成後通知 parent 資料已移除
     */
    @IBAction func actDel(sender: UIButton) {
    }
    
}