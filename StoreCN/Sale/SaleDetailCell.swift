//
// TableView Cell, Picker 數量選擇使用
//

import Foundation
import UIKit

/**
 * protocol, SaleDetailCell Delegate
 */
protocol SaleDetailCellDelegate {
    /**
     * Pickr view, 點取 '完成' / '取消'時， parent class 執行相關動作
     */
    func QtySelecteDone(SelectQty: Int, indexpath: NSIndexPath)
    func QtySelecteCancel()
}

/**
 * 出貨商品列表，點取的商品數量選擇
 */
class SaleDetailCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource, KBNavyBarDelegate {
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labId: UILabel!
    @IBOutlet weak var labPrice: UILabel!
    @IBOutlet weak var labQty: UILabel!
    @IBOutlet weak var labTot: UILabel!
    @IBOutlet weak var edQty: UITextField!
    @IBOutlet weak var labReturn: UILabel!
    
    // Delegate, public property
    var delegate = SaleDetailCellDelegate?()
    var kbHeight: CGFloat!
    
    private var pubClass = PubClass()
    
    // Picker 設定
    private let mKBNavyBar = KBNavyBar()
    private var mPKView = UIPickerView()
    private var aryRowVal: Array<String> = []  // Picker 的資料
    private var aryMaxMin = [1, 99] // 數量選擇，最小/最大 值
    
    // 其他設定
    private var currIndexPath: NSIndexPath!
    
    /**
     * Cell Load
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        mPKView.delegate = self
        
        // 設定每個 Picker row 的 array data
        for i in (aryMaxMin[0]..<(aryMaxMin[1] + 1)) {
            aryRowVal.append(String(i))
        }

        // 設定 edQty 彈出虛擬輸入鍵盤，樣式
        edQty.alpha = 0.0
        edQty.inputView = mPKView
        mKBNavyBar.delegate = self
        
        let toolbarKB = mKBNavyBar.getKBBar(pubClass.getLang("product_selectqty"))
        edQty.inputAccessoryView = toolbarKB
        kbHeight = toolbarKB.frame.height + mPKView.frame.height
    }
    
    /**
     * 初始與設定 Cell
     */
    func initView(ditItem: Dictionary<String, AnyObject>!, indexpath: NSIndexPath) {
        currIndexPath = indexpath
        
        // 設定 picker 預設選擇的數量
        mPKView.selectRow(Int(ditItem["qty"] as! String)! - 1, inComponent: 0, animated: true)
        
        // field 設定
        labName.text = ditItem["pdname"] as? String
        labId.text = ditItem["pdid"] as? String
        
        let intPrice = Int(ditItem["price"] as! String)!
        let intQty = Int(ditItem["qty"] as! String)!
        let totPrice = intPrice * intQty
        let intRQty = Int(ditItem["totRQty"] as! String)!
        
        labPrice.text = String(intPrice)
        labQty.text = String(intQty)
        labTot.text = String(totPrice)
        
        if (intRQty > 0) {
            labReturn.text = String(format: pubClass.getLang("FMT_alreadyrqty"), String(intRQty))
        } else {
            labReturn.alpha = 0.0
        }
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
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'done'
     */
    func KBBarDone() {
        edQty.resignFirstResponder()
        
        // 取得實際選取的 value
        delegate?.QtySelecteDone(Int(aryRowVal[mPKView.selectedRowInComponent(0)])!, indexpath: currIndexPath)
    }
    
    /**
     * #mark: KBNavyBarDelegate
     * 虛擬自訂鍵盤　toolbar 點取 'cancel'
     */
    func KBBarCancel() {
        edQty.resignFirstResponder()
        delegate?.QtySelecteCancel()
    }
    
}