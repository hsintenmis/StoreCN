//
//
//

import UIKit
import Foundation

/**
 * 商品管理選單
 * 進貨新增頁面 (店家進貨)
 */
class Purchase: UIViewController, PurchasePdSeltDelegate {
    
    // @IBOutlet
    @IBOutlet weak var labTotPrice: UILabel!
    @IBOutlet weak var edRealPrice: UITextField!
    @IBOutlet weak var edMemo: UITextField!
    
    // common property
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // public, 從 parent 設定
    var strToday = ""
    var dictMember: Dictionary<String, AnyObject> = [:]
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 商品資料設定
    private var aryPdType: Array<String>! // 商品分類
    private var dictCategoryPd: Dictionary<String, Array<Dictionary<String, String>>> = [:] // 已經分類完成的商品
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        dictPref = pubClass.getPrefData()
        aryPdType = pubClass.aryProductType
        
        // 重設商品分類 array data
        initAllPd()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
    * 重設商品分類 array data
    */
    private func initAllPd() {
        dictCategoryPd = [:]
        let aryAllPd = dictAllData["data"] as! Array<Dictionary<String, String>>
        
        var aryPd_S: Array<Dictionary<String, String>> = []
        var aryPd_C: Array<Dictionary<String, String>> = []
        var aryPd_N: Array<Dictionary<String, String>> = []
        var dictNewPd: Dictionary<String, String>
        
        for dictPd in aryAllPd {
            let strType: String! = dictPd["ptype"]
            dictNewPd = dictPd
            
            // 新增欄位, qtySel, qtyOrg
            dictNewPd["qtySel"] = "0"
            dictNewPd["qtyOrg"] = "0"
            
            if (strType == "S") {
                aryPd_S.append(dictNewPd)
            } else if(strType == "C") {
                aryPd_C.append(dictNewPd)
            } else {
                aryPd_N.append(dictNewPd)
            }
        }
        
        dictCategoryPd["S"] = aryPd_S
        dictCategoryPd["C"] = aryPd_C
        dictCategoryPd["N"] = aryPd_N
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {

    }
    
    /**
     * #mark: PurchasePdSeltDelegate
     * 商品選擇頁面，點取'完成'
     */
    func PdSeltPageDone(PdAllData dictData: Dictionary<String, Array<Dictionary<String, String>>>) {
        
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 商品選擇頁面
        if (strIdent == "PurchasePdSelt") {
            let mVC = segue.destinationViewController as! PurchasePdSelt
            mVC.strToday = strToday
            mVC.dictCategoryPd = sender as! Dictionary<String, Array<Dictionary<String, String>>>
        }
    }
    
    /**
     * act, 點取 '清空商品' button
     */
    @IBAction func actEmpty(sender: UIButton) {
    }
    
    /**
     * act, 點取 '選擇商品' button
     */
    @IBAction func actPdSelt(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("PurchasePdSelt", sender: dictCategoryPd)
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

