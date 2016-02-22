//
// Container直接加入一個 viewController
//

import UIKit
import Foundation

/**
 * 會員列表 + 新增刪除
 */
class MemberList: UIViewController, PubMemberSelectDelegate {
    
    // @IBOutlet
    @IBOutlet weak var containerMemberList: UIView!
    
    // common property
    let pubClass: PubClass = PubClass()
    var dictPref: Dictionary<String, AnyObject>!  // Prefer data
    var reloadMemberList = true
    
    // HTTP 回傳資料設定
    private var aryMember: Array<Dictionary<String, AnyObject>> = []

    // 其他參數設定
    private var strToday = ""
    private var mMemberData: Dictionary<String, AnyObject> = [:]  // 選擇的會員
    private var currIndexPath: NSIndexPath?  // 目前 TableView 的 IndexPath
    
    // 會員選擇公用 class
    private var mPubMemberSelect: PubMemberSelect!
    
    /**
     * View Load 程序
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 固定初始參數
        dictPref = pubClass.getPrefData()
        
        // 初始會員選擇公用 class
        mPubMemberSelect = storyboard!.instantiateViewControllerWithIdentifier("PubMemberList") as! PubMemberSelect
        mPubMemberSelect.delegate = self
    }
    
    /**
     * View DidAppear 程序
     */
    override func viewDidAppear(animated: Bool) {
        if (!reloadMemberList) {
            return
        }
        
        // HTTP 連線取得資料, 全部會員列表資料
        HTTPGetMemberList()
        
        dispatch_async(dispatch_get_main_queue(), {
            
        })
        
        reloadMemberList = false
    }
    
    /**
     * 初始與設定 VCview 內的 field
     */
    func initViewField() {
    }
    
    /**
     * HTTP 連線取得資料, 取得會員列表資料
     */
    private func HTTPGetMemberList() {
        // 連線 HTTP post/get 參數
        var dictParm = Dictionary<String, String>()
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
            pubClass.popIsee(self, Msg: pubClass.getLang("member_nodataaddfirst"))
            
            return
        }
        
        // !! container 直接加入 'PubMemberList'
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
        currIndexPath = indexPath
        mMemberData = dictData
        
        // HTTP 連線取得該會員全部資料(course, mead, soqibed, purchase)
        var dictParm = Dictionary<String, String>()
        dictParm["acc"] = pubClass.getAppDelgVal("V_USRACC") as? String
        dictParm["psd"] = pubClass.getAppDelgVal("V_USRPSD") as? String
        dictParm["page"] = "memberdata"
        dictParm["act"] = "memberdata_getdata"
        dictParm["arg0"] = dictData["memberid"] as? String
        
        // HTTP 開始連線
        pubClass.HTTPConn(self, ConnParm: dictParm, callBack: {(dictRS: Dictionary<String, AnyObject>)->Void in
            
            // 任何錯誤顯示錯誤訊息
            if (dictRS["result"] as! Bool != true) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.pubClass.popIsee(self, Msg: self.pubClass.getLang(dictRS["msg"] as? String))
                })
                
                return
            }
            
            /* 解析正確的 http 回傳結果，執行後續動作 */
            let dictData = (dictRS["data"]!["content"]!)!
            
            // 將整個回傳資料傳送下個頁面
            self.performSegueWithIdentifier("MemberMain", sender: dictData)
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
            let mVC = segue.destinationViewController as! MemberMain
            mVC.strToday = strToday
            mVC.dictMember = mMemberData
            mVC.dictAllData = sender as! Dictionary<String, AnyObject>
            
            return
        }
        
        // 新增會員
        if (strIdent == "MemberAdd") {
            let mVC = segue.destinationViewController as! MemberAdEd
            mVC.strToday = strToday
            mVC.strMode = "add"
            
            return
        }
        
        return
    }
    
    /**
     * act, 點取 '新增' button
     */
    @IBAction func actAdd(sender: UIBarButtonItem) {
        
    }
    
    /**
     * act, 點取 '返回' button
     */
    @IBAction func actBack(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

