//
// TableView Cell, Picker 數量選擇使用
//

import Foundation
import UIKit

/**
 * protocol, PurchasePdSeltCell Delegate
 */
protocol PurchasePdSeltCellDelegate {
    /**
     * Pickr view, 點取 '完成' / '取消'時， parent class 執行相關動作
     */
    func QtySelecteDone(SelectQty: Int)
    func QtySelecteCancel()
}

/**
* 商品選擇 TableView Cell，從進貨新增頁面轉入
*/
class PurchasePdSeltCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    @IBOutlet weak var labTot: UILabel!
    @IBOutlet weak var edQty: UITextField!
    
    // Delegate, public property
    var delegate = PurchasePdSeltCellDelegate?()
    var kbHeight: CGFloat!
    
    // Picker 設定
    private var pubClass = PubClass()
    private var mPKView = UIPickerView()
    private var aryRowVal: Array<String> = []  // Picker 的資料
    private var aryMaxMin = [0, 99] // 數量選擇，最小/最大 值
    
    /**
    * Cell Load
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        mPKView.delegate = self
 
        // 設定每個 Picker row 的 array data
        for i in (aryMaxMin[0]..<aryMaxMin[1]) {
            aryRowVal.append(String(i))
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        edQty.alpha = 0.0
        edQty.inputView = mPKView
        initKBBar(pubClass.getLang("product_selectqty"))
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
    }
    
    /**
     * 鍵盤輸入視窗的 'navybar' 設定
     * 顯示 '完成' 與 '取消'
     */
    private func initKBBar(strTitle: String) {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = false  // 半透明
        toolBar.barTintColor = pubClass.ColorHEX(pubClass.dictColor["silver"]!)  // 背景顏色
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: pubClass.getLang("select_ok"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PurchasePdSeltCell.SelectDone))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // 自訂一個 label 作為 NavyBar 的 Title
        let labTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200.0, height: 14.0))
        //let labTitle = UILabel()
        //labTitle.sizeToFit()
        
        labTitle.text = strTitle
        //labTitle.font = UIFont(name: "System", size: 14)
        
        labTitle.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: labTitle)
        
        let cancelButton = UIBarButtonItem(title: pubClass.getLang("cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(PurchasePdSeltCell.SelectCancel))
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        kbHeight = toolBar.frame.height + mPKView.frame.height
        
        edQty.inputAccessoryView = toolBar
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
        return aryRowVal.count
    }
    
    /**
     * #mark: UIPickerViewDelegate
     * 各個下拉選單，position 對應的 String
     */
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return aryRowVal[row]
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
        edQty.resignFirstResponder()
        delegate?.QtySelecteDone(mPKView.selectedRowInComponent(0))
    }
    
    /**
     * Picker 點取　'cancel'
     */
    @objc private func SelectCancel() {
        edQty.resignFirstResponder()
        delegate?.QtySelecteCancel()
    }

}