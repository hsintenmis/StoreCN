//
//
//

import UIKit
import Foundation

/**
 * 商品管理選單
 * 進貨新增頁面 (店家進貨)
 */
class Purchase: UIViewController {
    
    // @IBOutlet
    
    // common property
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    
    // public, 從 parent 設定
    var strToday = ""
    var dictMember: Dictionary<String, AnyObject> = [:]
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 商品資料設定
    private let aryPdType = ["S", "C", "N"] // 商品分類
    private var dictCategoryPd: Dictionary<String, Array<Dictionary<String, String>>> = [:] // 已經分類完成的商品
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        dictPref = pubClass.getPrefData()
        
        // 重設商品分類 array data
        let aryAllPd = dictAllData["data"] as! Array<Dictionary<String, String>>

        var aryPd_S: Array<Dictionary<String, String>> = []
        var aryPd_C: Array<Dictionary<String, String>> = []
        var aryPd_N: Array<Dictionary<String, String>> = []
        for dictPd in aryAllPd {
            let strType: String! = dictPd["ptype"]
            if (strType == "S") {
                aryPd_S.append(dictPd)
            } else if(strType == "C") {
                aryPd_C.append(dictPd)
            } else {
                aryPd_N.append(dictPd)
            }
        }
        
        dictCategoryPd["S"] = aryPd_S
        dictCategoryPd["C"] = aryPd_C
        dictCategoryPd["N"] = aryPd_N
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    private func initViewField() {

    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

