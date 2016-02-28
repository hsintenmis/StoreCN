//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 商品管理 - 進貨明細編輯
 */
class PurchaseDetailEdit: UIViewController {
    // Delegate
    var delegate = PubClassDelegate?()
    
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
        let dictData = vcChilePage!.getContainerPageDatai1()
        
        if (dictData == nil) {
            return
        }
        
        // 產生 http post data, http 連線儲存後跳離
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "purchase"
        dictParm["act"] = "purchase_editsave"
        
        do {
            let tmpDictData = try
                NSJSONSerialization.dataWithJSONObject(dictData!, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: tmpDictData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 開始連線
        pubClass.popConfirm(self, aryMsg: ["", pubClass.getLang("datasendplzconfirmmsg")], withHandlerYes: {self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: self.HttpSaveResponChk)}, withHandlerNo: { return })
    }
    
    /**
     * HTTP 連線後取得連線結果
     */
    private func HttpSaveResponChk(dictRS: Dictionary<String, AnyObject>) {
        // 回傳後跳離, 通知 parent 資料 reload
        let strMsg = (dictRS["result"] as! Bool != true) ? pubClass.getLang("err_trylatermsg") : pubClass.getLang("datasavecompleted")
        
        delegate?.PageNeedReload(true)
        pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
    }
    
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

