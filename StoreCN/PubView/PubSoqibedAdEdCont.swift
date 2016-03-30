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
    
    // 其他參數
    private var strIsDel = "N"
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view field 設定
        if (strMode == "add") {
            btnDel.enabled = false
            btnDel.alpha = 0.0
        }
        
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
            for i in (0..<aryItems.count) {
                let dictItem = aryItems[i]
                strRecords += pubClass.formatDateWithStr(dictItem["sdate"], type: 14)
                
                if (i < aryItems.count - 1) {
                    strRecords += "\n";
                }
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
     * public, parent 調用，回傳本頁面編輯資料
     */
    func getPageData()-> Dictionary<String, AnyObject>? {
        var dictData: Dictionary<String, AnyObject> = [:]
        
        // 名稱錯誤
        if (edTitle.text!.characters.count < 4) {
            pubClass.popIsee(self, Msg: pubClass.getLang("soqibed_titleerr"))
            
            return nil
        }
        
        // hothouse 設備 UISegmentedControl, 取得對應數值
        for swchDev in swchSoqbed {
            // 取得欄位名稱, ex. 'H00'
            let strIdent = swchDev.restorationIdentifier  // ex. 'DevH00'
            let strKey = strIdent!.stringByReplacingOccurrencesOfString("Dev1", withString: "", range: nil)
            
            dictData[strKey] = String(aryHotDevMinsVal[swchDev.selectedSegmentIndex])
        }
        
        dictData["S00"] = String(aryS00DevMinsVal[Int(sliderS00.value)])
        
        // 設定回傳資料
        dictData["mode"] = strMode
        dictData["del"] = strIsDel
        dictData["mead_id"] = dictAllData["mead_id"] as? String
        dictData["memberid"] = dictAllData["memberid"] as? String
        dictData["membername"] = dictAllData["membername"] as? String
        dictData["title"] = edTitle.text!
        dictData["index_id"] = dictAllData["index_id"] as? String

        return dictData
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