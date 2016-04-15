//
// TableView Cell, Picker 數量選擇使用
//

import Foundation
import UIKit

/**
 * protocol, PubPurReturnPdListCell Delegate
 */
protocol PubPurReturnPdListCellDelegate {
    /**
     * Pickr view, 點取 '完成' / '取消'時， parent class 執行相關動作
     */
    func QtySelecteDone(SelectQty: Int, indexPath: NSIndexPath)
    func QtySelecteCancel()
}

/**
 * 退貨商品選擇 TableView Cell，從進貨新增頁面轉入
 */
class PubPurReturnPdListCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, KBNavyBarDelegate {
    
    // Delegate, public property
    var delegate = PubPurReturnPdListCellDelegate?()
    var kbHeight: CGFloat!
    
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    @IBOutlet weak var labTot: UILabel!
    @IBOutlet weak var edQty: UITextField!
    
    // Picker 設定
    private var pubClass = PubClass()
    private var mPKView = UIPickerView()
    private var aryRowVal: Array<String> = []  // Picker 的資料
    private var aryMaxMin = [0, 99] // 數量選擇，最小/最大 值
    private var mKBNavyBar = KBNavyBar()  // 彈出的虛擬鍵盤, 上方的 UIToolbar
    
    // 其他設定
    private var intPrice = 0  // 商品單價
    private var currIndexPath: NSIndexPath!
    
    /**
    * Cell Load
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        aryRowVal = []
        mPKView.delegate = self
        mKBNavyBar.delegate = self
    }
    
    /**
     * 初始與設定 Cell
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, forIndexPath indexPath: NSIndexPath) {
        currIndexPath = indexPath
        
        // 設定每個 Picker row 的 array data
        aryMaxMin[1] = 0
        if let intTmp = Int(ditItem["maxqty"] as! String) {
            aryMaxMin[1] = intTmp
        }
        
        for i in (aryMaxMin[0]..<(aryMaxMin[1] + 1)) {
            aryRowVal.append(String(i))
        }
        
        // 設定 'mPickField' 點取彈出 '鍵盤視窗'
        edQty.inputView = mPKView
        let mToolBar = mKBNavyBar.getKBBar(pubClass.getLang("product_selectqty"))
        edQty.inputAccessoryView = mToolBar
        kbHeight = mToolBar.frame.height + mPKView.frame.height
        
        // 設定 picker 預設選擇的數量
        mPKView.selectRow(Int(ditItem["selQty"] as! String)!, inComponent: 0, animated: false)
        
        // field 設定
        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["pdid"] as? String
        
        intPrice = Int(ditItem["price"] as! String)!
        let intQty = Int(ditItem["selQty"] as! String)!
        let totPrice = intPrice * intQty
        
        labPrice.text = String(intPrice)
        labQty.text = String(aryMaxMin[1])
        labTot.text = String(totPrice)
        edQty.text = String(intQty)
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
     * #mark: 自訂的 KBNavyBarDelegate
     * Picker 點取　'done'
     */
    func KBBarDone() {
        edQty.resignFirstResponder()
        
        // filed value 重新設定
        let intQty = Int(aryRowVal[mPKView.selectedRowInComponent(0)])!
        edQty.text = String(intQty)
        labTot.text = String(intQty * intPrice)
        
        // delegate 設定
        delegate?.QtySelecteDone(Int(aryRowVal[mPKView.selectedRowInComponent(0)])!, indexPath: currIndexPath)
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