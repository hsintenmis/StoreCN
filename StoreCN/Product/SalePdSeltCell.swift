//
// TableView Cell, Picker 數量選擇使用
//

import Foundation
import UIKit

/**
 * protocol, SalePdSeltCell Delegate
 */
protocol SalePdSeltCellDelegate {
    /**
     * Pickr view, 點取 '完成' / '取消'時， parent class 執行相關動作
     */
    func QtySelecteDone(SelectQty: Int)
    func QtySelecteCancel()
}

/**
 * 商品選擇 TableView Cell，從 [商品銷售] 頁面轉入
 */
class SalePdSeltCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, KBNavyBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    @IBOutlet weak var labTot: UILabel!
    @IBOutlet weak var edQty: UITextField!
    @IBOutlet weak var labStock: UILabel!
    
    // Delegate, public property
    var delegate = SalePdSeltCellDelegate?()
    var kbHeight: CGFloat!
    var intStock: Int!  // 目前庫存量， parent 設定
    
    private var pubClass = PubClass()
    
    // Picker 設定
    private var mKBNavyBar = KBNavyBar()  // 彈出的虛擬鍵盤, 上方的 UIToolbar
    private var mPKView = UIPickerView()
    private var aryRowVal: Array<String> = []  // Picker 的資料
    private var aryMaxMin = [0, 99] // 數量選擇，最小/最大 值
    
    /**
    * Cell Load
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        mPKView.delegate = self
        mKBNavyBar.delegate = self
        edQty.delegate = self
        
        /*
        // 設定每個 Picker row 的 array data
        for (var i = aryMaxMin[0]; i <= aryMaxMin[1]; i++) {
            aryRowVal.append(String(i))
        }
        */
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        edQty.alpha = 0.0
        edQty.inputView = mPKView
        let mToolBar = mKBNavyBar.getKBBar(pubClass.getLang("product_selectqty"))
        edQty.inputAccessoryView = mToolBar
        kbHeight = mToolBar.frame.height + mPKView.frame.height
    }
    
    /**
     * 初始與設定 Cell
     */
    func initView(ditItem: Dictionary<String, AnyObject>!) {
        // 設定 picker 預設選擇的數量
        mPKView.selectRow(Int(ditItem["qtySel"] as! String)!, inComponent: 0, animated: false)
        
        // field 設定
        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["pdid"] as? String
        labStock.text = ditItem["qty"] as? String
        
        let intPrice = Int(ditItem["price"] as! String)!
        let intQty = Int(ditItem["qtySel"] as! String)!
        let totPrice = intPrice * intQty
        
        labPrice.text = String(intPrice)
        labQty.text = String(intQty)
        labTot.text = String(totPrice)
        
        // 顏色,樣式 相關設定
        let mColor =  (Int(ditItem["qtySel"] as! String) > 0) ? pubClass.ColorHEX(pubClass.dictColor["BlueDark"]!) : pubClass.ColorHEX(pubClass.dictColor["gray"]!)
        labQty.textColor = mColor
        labTot .textColor = mColor
        
        intStock = Int(ditItem["qty"] as! String)!
        /*
        // 重新設定 '數量' 彈出鍵盤，最大值改為庫存數
        aryRowVal = []
        for (var i = aryMaxMin[0]; i <= Int(ditItem["qty"] as! String)!; i++) {
            aryRowVal.append(String(i))
        }
        mPKView.reloadAllComponents()
        */
    }
    
    /**
     * #mark: UITextFieldDelegate Delegate
     *  edit 欄位開始編輯
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        // 重新設定 '數量' 彈出鍵盤，最大值改為庫存數
        aryRowVal = []
        for (var i = aryMaxMin[0]; i <= intStock; i++) {
            aryRowVal.append(String(i))
        }
        mPKView.reloadAllComponents()
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
        return (aryRowVal.count > 0) ? aryRowVal.count : 1
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (aryRowVal.count > 0) ? aryRowVal[row] : ""
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
        edQty.resignFirstResponder()
        delegate?.QtySelecteDone(mPKView.selectedRowInComponent(0))
    }
    
    /**
     * #mark: 自訂的 KBNavyBarDelegate
     * Picker 點取　'cancel'
     */
    func KBBarCancel() {
        edQty.resignFirstResponder()
        delegate?.QtySelecteCancel()
    }
    
}