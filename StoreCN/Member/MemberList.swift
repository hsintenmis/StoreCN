//
// Container直接加入一個 viewController
//

import UIKit
import Foundation

/**
 * 會員列表 + 新增刪除
 */
class MemberList: UIViewController, PubMemberSelectDelegate, PubClassDelegate {
    
    // @IBOutlet
    @IBOutlet weak var containerMemberList: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    
    // HTTP 回傳資料設定
    private var aryMember: Array<Dictionary<String, AnyObject>> = []

    // 其他參數設定
    private var strToday = ""
    private var currIndexPath: NSIndexPath?  // 目前 TableView 的 IndexPath
    
    // 會員選擇公用 class
    private var mPubMemberSelect: PubMemberSelect!
    private var mMemberHttpData: MemberHttpData!  // http 連線取得會員全部資料
    
    // 其他參數
    private var bolReload = true  // 本頁面是否需要 reload
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mMemberHttpData = MemberHttpData(VC: self)
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (bolReload == true) {
            bolReload = false
            
            // 初始會員選擇公用 class
            mPubMemberSelect = storyboard!.instantiateViewControllerWithIdentifier("PubMemberList") as! PubMemberSelect
            mPubMemberSelect.delegate = self
            
            // HTTP 連線取得資料, 全部會員列表資料
            HTTPGetMemberList()
        }
    }
    
    /**
     * #mark: PubClassDelegate,  child 通知本頁面資料重整
     */
    func PageNeedReload(needReload: Bool) {
        if (needReload == true) {
            bolReload = true
        }
    }
    
    /**
     * HTTP 連線取得資料, 取得會員列表資料
     */
    private func HTTPGetMemberList() {
        // 連線 HTTP post/get 參數
        var dictParm: Dictionary<String, String> = [:]
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "member"
        dictParm["act"] = "member_getdata"
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: dictParm, callBack: HTTPResponMemberList)
    }
    
    /**
     * HTTP 連線後取得連線結果, 會員列表資料
     * 資料 key name：data, course, member 型態為 Array<Dictionary<String, AnyObject>>
     */
    private func HTTPResponMemberList(dictRS: Dictionary<String, AnyObject>) {
        // 任何錯誤跳離
        if (dictRS["result"] as! Bool != true) {
            dispatch_async(dispatch_get_main_queue(), {
                self.pubClass.popIsee(self, Msg: self.pubClass.getLang(dictRS["msg"] as? String), withHandler: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
            
            return
        }
        
        /* 解析正確的 http 回傳結果，執行後續動作 */
        let dictData = (dictRS["data"]!["content"]!)!
        
        strToday = dictData["today"] as! String
        
        // 設定會員資料 array data
        if let tmpData = dictData["data"] as? Array<Dictionary<String, AnyObject>> {
            aryMember = tmpData
        } else {
            currIndexPath = nil
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"))
            
            return
        }
        
        // !! container 直接加入 'PubMemberList'
        mPubMemberSelect.removeFromParentViewController()
        
        mPubMemberSelect.aryMember = aryMember
        mPubMemberSelect.currIndexPath = currIndexPath
        let mView = mPubMemberSelect.view
        mView.frame.size.height = containerMemberList.layer.frame.height
        self.containerMemberList.addSubview(mView)
        
        self.navigationController?.pushViewController(mPubMemberSelect, animated: true)
    }
    
    /**
    * #mark: PubMemberListDelegate, 會員列表，點取會員執行相關程序
    */
    func MemberSelected(MemberData dictData: Dictionary<String, AnyObject>, indexPath: NSIndexPath) {
        
        // http 連線取得會員全部相關資料
        mMemberHttpData.connGetData(dictData["memberid"] as! String, connCallBack: {
            (dictAllMemberData) -> Void in
            
            // 回傳資料失敗
            if (dictAllMemberData["result"] as! Bool != true) {
                var errMsg = dictAllMemberData["err"] as! String
                if (errMsg.characters.count < 1)  {
                    errMsg = self.pubClass.getLang("err_systemmaintain")
                }
                
                self.pubClass.popIsee(self, Msg: errMsg)
                
                return
            }
            
            // 回傳資料設定到傳送下個頁面
            self.currIndexPath = indexPath
            self.performSegueWithIdentifier("MemberMain", sender: dictAllMemberData)
        })
    }
    
    /**
     * #mark: UITableView Delegate
     * UITableView, Cell 刪除，cell 向左滑動
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // 彈出 confirm 視窗, 點取 'OK' 執行實際刪除資料程序
            
            return
        }
    }
    
    /**
     * Segue 跳轉頁面
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let strIdent = segue.identifier
        
        // 會員主頁面
        if (strIdent == "MemberMain") {
            let mDictData = sender as! Dictionary<String, AnyObject>
            let mVC = segue.destinationViewController as! MemberMain
            mVC.strToday = strToday
            mVC.dictAllData = mDictData
            mVC.dictMember = (mDictData["datamember"] as! Array<Dictionary<String, AnyObject>>)[0]
            mVC.delegate = self
            
            return
        }
        
        // 新增會員
        if (strIdent == "MemberAdd") {
            currIndexPath = nil
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "add"
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}