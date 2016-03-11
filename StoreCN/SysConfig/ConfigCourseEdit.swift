//
// TablkeView Static, UITextFieldDelegate, UIPicker
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class ConfigCourseEdit: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, KBNavyBarDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var edHH0: UITextField!
    @IBOutlet weak var edHH1: UITextField!
    @IBOutlet weak var labSrvNums: UILabel!
    @IBOutlet weak var slidNums: UISlider!

    // common property
    private var pubClass: PubClass!
    
    // public property, 上層 parent 設定
    
    // 其他設定
    private var dictAllData: Dictionary<String, AnyObject> = [:]  // 本頁面需要的資料
    
    // 鍵盤下拉選單 '時' 選擇相關參數
    private var mKBNavyBar = KBNavyBar()  // 彈出的虛擬鍵盤, 上方的 UIToolbar
    private var mPKView = UIPickerView()
    private var aryValHH: Array<String> = []
    private var currEdField: UITextField?
    private let strPreFixHHunit = "时" // 下拉選單，選擇'時'單位
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        mPKView.delegate = self
        mKBNavyBar.delegate = self
        
        // 鍵盤下拉選單 '時' 選擇相關參數
        for (var i=0; i < 24; i++) {
            aryValHH.append(String(i) + strPreFixHHunit )
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        edHH0.inputView = mPKView
        edHH0.inputAccessoryView = mKBNavyBar.getKBBar("")
        
        edHH1.inputView = mPKView
        edHH1.inputAccessoryView = mKBNavyBar.getKBBar("")
    }
    
    override func viewDidAppear(animated: Bool) {
        reConnHTTP()
    }
    
    /**
     * 頁面資料重整，檢查是否有資料
     */
    private func relaodPage() {
        // 設定 '星期幾' Static Cell
        if let strWeek = dictAllData["course_rest"] as? String {
            if (strWeek.characters.count > 0) {
                let aryWeek = Array(strWeek.characters)
                
                for strChart in aryWeek {
                    let mIndexPath = NSIndexPath(forItem: Int(String(strChart))!, inSection: 1)
                    let mCell = tableList.cellForRowAtIndexPath(mIndexPath)!
                    mCell.accessoryType = .Checkmark
                }
            }
        }
        
        // 其他欄位設定
        edHH0.text = dictAllData["course_hh0"] as? String
        edHH1.text = dictAllData["course_hh1"] as? String
        
        // 設定服務人數
        let strNums = dictAllData["course_srvnums"] as! String
        labSrvNums.text = strNums
        slidNums.value = Float(Int(strNums)!)
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // Request 參數設定
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "homepage"
        mParam["act"] = "homepage_getcourseconfig"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離
            if (dictRS["result"] as! Bool != true) {
                var errMsg = self.pubClass.getLang("err_trylatermsg")
                if let tmpStr: String = dictRS["msg"] as? String {
                    errMsg = self.pubClass.getLang(tmpStr)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: errMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {})})
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            self.dictAllData = dictData["data"] as! Dictionary<String, AnyObject>
            self.relaodPage()
        })
    }
    
    /**
     * #mark: UITextFieldDelegate Delegate
     *  edit 欄位開始編輯
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        currEdField = textField
        
        // 設定 picker 預設選擇的數量, '時' 的下拉選單
        let strHH = textField.text! + strPreFixHHunit
        for (var i=0; i < aryValHH.count; i++) {
            if (aryValHH[i] == strHH) {
                mPKView.selectRow(i, inComponent: 0, animated: true)
                
                break
            }
        }
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 處理 '星期幾' 點取狀態, section = 1
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section != 1) {
            return
        }
        
        let mCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if (mCell.accessoryType == .Checkmark) {
            mCell.accessoryType = .None
        } else {
            mCell.accessoryType = .Checkmark
        }
        
        return
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 有幾個 '下拉選單'
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，有幾筆資料
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryValHH.count
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return aryValHH[row]
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，點取 Item 後執行相關程序
     */
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    /**
     * #mark: 自訂的 KBNavyBarDelegate
     * Picker 點取　'done'
     */
    func KBBarDone() {
        let position = mPKView.selectedRowInComponent(0)
        currEdField?.text = String(position)
        currEdField?.resignFirstResponder()
    }
    
    /**
     * #mark: 自訂的 KBNavyBarDelegate
     * Picker 點取　'cancel'
     */
    func KBBarCancel() {
        currEdField?.resignFirstResponder()
    }
    
    /**
    * act, Slider 滑動改變人數
    */
    @IBAction func actSliderChangNums(sender: UISlider) {
        labSrvNums.text = String(Int(sender.value))
    }
    
    /**
    * public
    * 取得本頁面編修的資料，parent 調用
    */
    func getPageData() -> Dictionary<String, String>! {
        var dictRS: Dictionary<String, String> = [:]
        
        dictRS["course_hh0"] = edHH0.text
        dictRS["course_hh1"] = edHH1.text
        dictRS["course_srvnums"] = labSrvNums.text
        
        var strRest = ""
        for (var i=0; i < 7; i++) {
            let mIndexPath = NSIndexPath(forItem: i, inSection: 1)
            let mCell = tableList.cellForRowAtIndexPath(mIndexPath)!
            
            if (mCell.accessoryType == .Checkmark) {
                strRest += String(i)
            }
        }
        dictRS["course_rest"] = strRest
        
        return dictRS
    }
    
}