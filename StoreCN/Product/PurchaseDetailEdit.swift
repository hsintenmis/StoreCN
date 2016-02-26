//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨明細編輯
 */
class PurchaseDetailEdit: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // container page VC
    var vcChilePage: PurchaseDetailEditContainer?
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func initViewField() {
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "containerPurchaseDetailEdit") {
            vcChilePage = segue.destinationViewController as? PurchaseDetailEditContainer
            vcChilePage!.strToday = strToday
            vcChilePage!.dictAllData = dictAllData
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictData = vcChilePage!.getContainerPageData1()
        
        if (dictData == nil) {
            return
        }
        
        // TODO, HTTP 連線資料儲存
        print(dictData)
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

