//
// with ContainerView
//

import UIKit
import Foundation

/**
 * 出貨明細編輯
 */
class SaleDetailEdit: UIViewController {
    // Delegate
    var delegate = PubClassDelegate?()
    
    // @IBOutlet
    @IBOutlet weak var containView: UIView!
    
    // common property
    let pubClass = PubClass()
    
    // public property, 上層 parent 設定
    var strToday: String!
    var dictAllData: Dictionary<String, AnyObject> = [:]
    
    // container page VC
    var mSaleDetailEditCont: SaleDetailEditCont!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        if (strIdent == "containerSaleDetailEdit") {
            mSaleDetailEditCont = segue.destinationViewController as? SaleDetailEditCont
            mSaleDetailEditCont!.strToday = strToday
            mSaleDetailEditCont!.dictAllData = dictAllData
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '儲存' button
     */
    @IBAction func actSave(sender: UIBarButtonItem) {
        let dictData = mSaleDetailEditCont.getPageData()
        
        if (dictData == nil) {
            return
        }
        
        // 產生 http post data, http 連線儲存後跳離
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "sale"
        dictParm["act"] = "sale_editsave_otherdta"
        
        do {
            let tmpDictData = try
                NSJSONSerialization.dataWithJSONObject(dictData!, options: NSJSONWritingOptions(rawValue: 0))
            let jsonString = NSString(data: tmpDictData, encoding: NSUTF8StringEncoding)! as String
            
            dictParm["arg0"] = jsonString
        } catch {
            pubClass.popIsee(self, Msg: pubClass.getLang("err_data"))
            
            return
        }
        
        // HTTP 開始連線, confirm 視窗
        pubClass.popConfirm(self, aryMsg: [self.pubClass.getLang("systemwarring"), pubClass.getLang("datasendplzconfirmmsg")], withHandlerYes: {self.pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {
            (dictRS: Dictionary<String, AnyObject>) -> Void in
            
            // 回傳後跳離, 通知 parent 資料 reload
            let bolRS = dictRS["result"] as! Bool
            let strMsg = (bolRS != true) ? self.pubClass.getLang("err_trylatermsg") : self.pubClass.getLang("datasavecompleted")
            
            self.pubClass.popIsee(self, Msg: strMsg, withHandler: {self.dismissViewControllerAnimated(true, completion: {self.delegate?.PageNeedReload!(bolRS)})})
            
        })}, withHandlerNo: {})

    }
    
    /**
    * 編輯資料 http 連線儲存
    */
    private func saveData(dictData: Dictionary<String, AnyObject>!) {

    }
    
    /**
     * act, btn '返回'
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}