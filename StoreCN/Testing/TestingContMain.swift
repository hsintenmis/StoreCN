//
// Container 主頁面, Static TableView
//

import UIKit
import Foundation

/**
 * 藍牙設備裝置選擇主頁面，點取後跳轉對應的藍牙設備檢測頁面
 * 本頁面順便產生全部會員資料，傳入檢測主頁面選擇會員
 */
class TestingContMain: UITableViewController {
    
    // @IBOutlet
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // 本頁面需要的全部資料
    private var strToday = ""
    private var dictAllData: Dictionary<String, AnyObject> = [:]
    private var aryMember: Array<Dictionary<String, AnyObject>> = []
    
    // 其他參數設定
    private var bolReload = true
    
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
        if (bolReload == true) {
            bolReload = false
            reConnHTTP()
        }
    }
    
    /**
     * 檢查是否有資料與頁面重整
     */
    private func chkHaveData() {
        // 檢查是否有會員
        if let tmpData = dictAllData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        } else {
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"), withHandler: {
                self.dismissViewControllerAnimated(true, completion: {})
            })
            
            return
        }
    }
    
    /**
     * HTTP 重新連線取得資料
     */
    private func reConnHTTP() {
        // http 參數設定, 連線設定，判別 parent '療程管理列表' or '會員管理的療程列表'
        var mParam: Dictionary<String, String> = [:]
        mParam["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        mParam["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        mParam["page"] = "member"
        mParam["act"] = "member_getdata"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: mParam, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤跳離本頁
            if (dictRS["result"] as! Bool != true) {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang("err_trylatermsg"), withHandler: {self.dismissViewControllerAnimated(true, completion: nil)})
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = dictRS["data"]!["content"] as! Dictionary<String, AnyObject>
            
            self.strToday = dictData["today"] as! String
            self.dictAllData = dictData
            self.chkHaveData()
        })
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 點取
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 體脂計主頁面
        if (strIdent == "BTScaleMain") {
            let mVC = segue.destinationViewController as! BTScaleMain
            mVC.strToday = self.strToday
            mVC.aryMember = self.aryMember
            
            return
        }
        
        // 能量檢測主頁面
        if (strIdent == "BTMeadMain") {
            let mVC = segue.destinationViewController as! BTMeadMain
            mVC.strToday = self.strToday
            mVC.aryMember = self.aryMember
            
            return
        }

        return
    }
    
}