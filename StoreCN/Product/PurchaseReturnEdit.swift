//
// with ContainerView, 調用公用 class 'PubPurReturnPdList'
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨退回，編輯退貨項目與相關資料
 */
class PurchaseReturnEdit: UIViewController, PubPurReturnPdListDelegate {
    // @IBOutlet
    @IBOutlet weak var labAmount: UILabel!
    @IBOutlet weak var edRDate: UITextField!
    @IBOutlet weak var edCustPrice: UITextField!
    @IBOutlet weak var swchDelAll: UISwitch!
    @IBOutlet weak var btnDelAll: UIButton!

    @IBOutlet weak var containView: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    var dictReturn: Dictionary<String, AnyObject>!
    var dictPurchasePd: Dictionary<String, AnyObject>!
    
    // 其他參數
    private var aryReturnPd: Array<Dictionary<String, AnyObject>>!  // 退貨商品 array
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定退貨商品 array data, 加入數量相關欄位
        aryReturnPd = dictReturn["pd"] as! Array<Dictionary<String, AnyObject>>

        for (var i=0; i < aryReturnPd.count; i++) {
            let pdid = aryReturnPd[i]["pdid"] as! String
            let dictPd = dictPurchasePd[pdid]!
            
            var intMax = Int(dictPd["maxqty"] as! String)!
            let intSel = Int(aryReturnPd[i]["qty"] as! String)!
            let intReturn = Int(dictPd["totRQty"] as! String)!
            
            intMax = intMax + intSel
            aryReturnPd[i]["selQty"] =  String(intSel)
            aryReturnPd[i]["maxqty"] = String(intMax)
            aryReturnPd[i]["totRQty"] = String(intReturn)
        }
        
        // field 設定
        btnDelAll.alpha = 0.0
    }
    
    /**
     * View WillAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        // 初始公用 class 退貨商品列表 'PubPurReturnPdList'
        let mPubPurReturnPdList = storyboard!.instantiateViewControllerWithIdentifier("PubPurReturnPdList") as! PubPurReturnPdList
        
        mPubPurReturnPdList.delegate = self
        mPubPurReturnPdList.aryData = aryReturnPd
        mPubPurReturnPdList.strToday = strToday
        
        // ContainerView 加入 vc 'PubPurReturnPdList'        
        let mView = mPubPurReturnPdList.view
        mView.frame.size.height = containView.layer.frame.height
        self.containView.addSubview(mView)
        self.navigationController?.pushViewController(mPubPurReturnPdList, animated: true)
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let strIdent = segue.identifier
        
        return
    }
    
    /**
     * #mark: PubPurReturnPdListDelegate
     * 退貨商品數量改變，本頁面相關資料變動
     */
    func PdQtyChange(SelectQty: Int, indexPath: NSIndexPath) {


    }
    
    /**
     * act, switch 退貨全部取消
     */
    @IBAction func actSwchDelAll(sender: UISwitch) {
        btnDelAll.alpha = (sender.on) ? 1.0 : 0.0
    }
    
    /**
     * act, 點取 '確定' button, 退貨全部取消
     */
    @IBAction func actDelAll(sender: UIButton) {
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {

    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

