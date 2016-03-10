//
// TablkeView Static, UITextFieldDelegate
//

import UIKit
import Foundation

/**
 * 會員 新增/編輯
 */
class ConfigCourseEdit: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // @IBOutlet
    @IBOutlet var tableList: UITableView!
    
    @IBOutlet weak var edHH_Start: UITextField!
    @IBOutlet weak var edHH_End: UITextField!
    @IBOutlet weak var edNums: UITextField!
    
    // UICell 對應星期幾, 一 ~  六日
    @IBOutlet var groupWeekCell: [UITableViewCell]!
    
    // common property
    var pubClass: PubClass!
    
    // public property, 上層 parent 設定
    
    // 其他設定
    private var aryWeekVal: Array<Bool> = []
    
    // 鍵盤下拉選單 '時' 選擇相關參數
    private var mPKView = UIPickerView()
    private var aryValHH: Array<String> = []
    private var currEdField: UITextField?
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        pubClass = PubClass()
        mPKView.delegate = self
        
        // TODO 設定 field 初始值
        
        // 設定 星期幾 Cell
        for (var i=0; i < 7; i++) {
            aryWeekVal.append(false)
            
            if (aryWeekVal[i] == true) {
                groupWeekCell[i].accessoryType = .Checkmark
            } else {
                groupWeekCell[i].accessoryType = .None
            }
        }
        
        // 鍵盤下拉選單 '時' 選擇相關參數
        for (var i=0; i < 24; i++) {
            aryValHH.append(String(i) + " 時")
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        edHH_Start.inputView = mPKView
        edHH_End.inputView = mPKView
        initKBBar("", editField: edHH_Start)
        initKBBar("", editField: edHH_End)
    }
    
    /**
     * 鍵盤輸入視窗的 'navybar' 設定
     * 顯示 '完成' 與 '取消'
     */
    private func initKBBar(strTitle: String, editField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = false  // 半透明
        toolBar.barTintColor = pubClass.ColorHEX(pubClass.dictColor["silver"]!)  // 背景顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("select_ok"), style: UIBarButtonItemStyle.Plain, target: self, action: "SelectDone")
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // 自訂一個 label 作為 NavyBar 的 Title
        let labTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 14.0))
        //let labTitle = UILabel()
        //labTitle.sizeToFit()
        
        labTitle.text = strTitle
        //labTitle.font = UIFont(name: "System", size: 14)
        
        labTitle.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: labTitle)
        
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: "SelectCancel")
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        //kbHeight = toolBar.frame.height + mPKView.frame.height
        
        editField.inputAccessoryView = toolBar
    }
    
    /**
     * #mark: UITextFieldDelegate Delegate
     *  edit 欄位開始編輯
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        currEdField = textField
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取, 處理 '星期幾' 點取狀態, section = 1
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section != 1) {
            return
        }
        
        let position = indexPath.row
        aryWeekVal[position] = !aryWeekVal[position]
        
        if (aryWeekVal[position] == true) {
            groupWeekCell[position].accessoryType = .Checkmark
        } else {
            groupWeekCell[position].accessoryType = .None
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
     * Picker 點取　'done'
     */
    @objc private func SelectDone() {
        currEdField?.resignFirstResponder()
    }
    
    /**
     * Picker 點取　'cancel'
     */
    @objc private func SelectCancel() {
        currEdField?.resignFirstResponder()
    }
    
}