//
// TableView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨明細主頁面
 */
class PurchaseListDetail: UIViewController {
    
    // @IBOutlet
    @IBOutlet weak var tableData: UITableView!
    @IBOutlet weak var labSdate: UILabel!
    @IBOutlet weak var labHteid: UILabel!
    @IBOutlet weak var labAmount: UILabel!
    @IBOutlet weak var labCustPrice: UILabel!
    @IBOutlet weak var labReturnAmount: UILabel!

    // common property
    let pubClass: PubClass = PubClass()
    
    // public, 本頁面需要的全部資料, parent 設定
    var strToday = ""
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // 其他參數設定
    private var mAlert: UIAlertController!  // alertView 功能選單
    
    /**
    * View Load 程序
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        //設定 alertView 功能選單
        setAlertVC()
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    /**
     * 設定 alertView 功能選單
     */
    private func setAlertVC() {
        // 彈出 ActionSheet 子選單, 提供：編輯 / 新增退貨 / 退貨明細
        mAlert = UIAlertController(title: pubClass.getLang(""), message: nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        // 設定選單項目, 對應 ident string
        let aryIdent = ["purchase_detailedit", "purchase_returnadd", "purchase_returnlist"]
        
        // loop 子選單 ident name, 重新產生 UIAlertController
        for strIdent in aryIdent {
            mAlert.addAction(UIAlertAction(title:pubClass.getLang("product_" + strIdent), style: UIAlertActionStyle.Default, handler:{
                (alert: UIAlertAction!)->Void in
                
                // 執行 'prepareForSegue' 跳轉指定頁面
                self.performSegueWithIdentifier(strIdent, sender: nil)
            }))
        }
        
        mAlert.addAction(UIAlertAction(title: pubClass.getLang("cancel"), style: UIAlertActionStyle.Destructive, handler:nil))
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 編輯
        if (strIdent == "purchase_detailedit") {
            let mVC = segue.destinationViewController as! PurchaseDetailEdit
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            
            return
        }
        
        // 新增退貨
        if (strIdent == "purchase_returnadd") {
            let mVC = segue.destinationViewController as! PurchaseReturnAdd
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            
            return
        }
        
        // 退貨明細
        if (strIdent == "purchase_returnlist") {
            let mVC = segue.destinationViewController as! PurchaseListDetail
            mVC.dictAllData = dictAllData
            mVC.strToday = strToday
            
            return
        }
    }
    
    /**
     * act, 點取 '功能' button
     */
    @IBAction func actOption(sender: UIBarButtonItem) {
        self.presentViewController(mAlert, animated: true, completion: nil)
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actHome(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}